package com.videovocab.video_vocab_app

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder

class MainActivity : FlutterActivity() {
    companion object {
        private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "video_vocab/audio")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "extractWav" -> {
                        val input = call.argument<String>("input")!!
                        val output = call.argument<String>("output")!!
                        val sampleRate = call.argument<Int>("sampleRate") ?: 16000
                        scope.launch {
                            try {
                                extractAudioToWav(input, output, sampleRate)
                                withContext(Dispatchers.Main) { result.success(output) }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("EXTRACT_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                    "convertToMp4" -> {
                        val input = call.argument<String>("input")!!
                        val output = call.argument<String>("output")!!
                        scope.launch {
                            try {
                                remuxToMp4(input, output)
                                withContext(Dispatchers.Main) { result.success(output) }
                            } catch (e: Exception) {
                                withContext(Dispatchers.Main) {
                                    result.error("CONVERT_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun extractAudioToWav(inputPath: String, outputPath: String, targetSampleRate: Int) {
        val extractor = MediaExtractor()
        extractor.setDataSource(inputPath)

        var audioTrackIndex = -1
        var audioFormat: MediaFormat? = null
        for (i in 0 until extractor.trackCount) {
            val format = extractor.getTrackFormat(i)
            val mime = format.getString(MediaFormat.KEY_MIME) ?: continue
            if (mime.startsWith("audio/")) {
                audioTrackIndex = i
                audioFormat = format
                break
            }
        }

        if (audioTrackIndex == -1 || audioFormat == null) {
            extractor.release()
            throw Exception("No audio track found")
        }

        extractor.selectTrack(audioTrackIndex)

        val mime = audioFormat.getString(MediaFormat.KEY_MIME)!!
        val srcSampleRate = audioFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val srcChannels = audioFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT)

        val codec = MediaCodec.createDecoderByType(mime)
        codec.configure(audioFormat, null, null, 0)
        codec.start()

        // Decode audio to a temp PCM file (streaming, not in memory)
        val tempPcm = File(outputPath + ".pcm.tmp")
        val pcmOut = FileOutputStream(tempPcm)
        val bufferInfo = MediaCodec.BufferInfo()
        var isEOS = false

        try {
            while (true) {
                if (!isEOS) {
                    val inputIndex = codec.dequeueInputBuffer(10000)
                    if (inputIndex >= 0) {
                        val inputBuffer = codec.getInputBuffer(inputIndex)!!
                        val sampleSize = extractor.readSampleData(inputBuffer, 0)
                        if (sampleSize < 0) {
                            codec.queueInputBuffer(inputIndex, 0, 0, 0,
                                MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            isEOS = true
                        } else {
                            codec.queueInputBuffer(inputIndex, 0, sampleSize,
                                extractor.sampleTime, 0)
                            extractor.advance()
                        }
                    }
                }

                val outputIndex = codec.dequeueOutputBuffer(bufferInfo, 10000)
                if (outputIndex >= 0) {
                    if (bufferInfo.size > 0) {
                        val outputBuffer = codec.getOutputBuffer(outputIndex)!!
                        val chunk = ByteArray(bufferInfo.size)
                        outputBuffer.get(chunk)
                        pcmOut.write(chunk)
                    }
                    codec.releaseOutputBuffer(outputIndex, false)

                    if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                        break
                    }
                } else if (outputIndex == MediaCodec.INFO_TRY_AGAIN_LATER && isEOS) {
                    break
                }
            }
        } finally {
            pcmOut.close()
            codec.stop()
            codec.release()
            extractor.release()
        }

        // Convert temp PCM to target WAV (mono, resampled) in chunks
        convertPcmToWav(tempPcm, outputPath, srcSampleRate, srcChannels, targetSampleRate)
        tempPcm.delete()
    }

    private fun convertPcmToWav(
        pcmFile: File,
        outputPath: String,
        srcRate: Int,
        srcChannels: Int,
        dstRate: Int
    ) {
        val srcBytesPerSample = 2 * srcChannels // 16-bit * channels
        val totalSrcSamples = pcmFile.length() / srcBytesPerSample
        val totalDstSamples = (totalSrcSamples * dstRate / srcRate)
        val dstDataSize = (totalDstSamples * 2).toInt() // 16-bit mono

        val raf = RandomAccessFile(outputPath, "rw")
        try {
            // Write WAV header (44 bytes)
            writeWavHeader(raf, dstRate, 1, dstDataSize)

            // Process in chunks: read source PCM, convert to mono, resample, write
            val chunkSrcSamples = 8192
            val chunkBytes = chunkSrcSamples * srcBytesPerSample
            val readBuf = ByteArray(chunkBytes)
            val fis = FileInputStream(pcmFile)

            var srcSampleOffset = 0L
            var dstSampleWritten = 0L

            try {
                while (true) {
                    val bytesRead = fis.read(readBuf)
                    if (bytesRead <= 0) break

                    val samplesInChunk = bytesRead / srcBytesPerSample
                    val srcBuf = ByteBuffer.wrap(readBuf, 0, bytesRead).order(ByteOrder.LITTLE_ENDIAN)

                    // Determine how many dst samples map to this chunk's source range
                    val chunkEndSrcSample = srcSampleOffset + samplesInChunk
                    val dstStart = (srcSampleOffset * dstRate / srcRate)
                    val dstEnd = (chunkEndSrcSample * dstRate / srcRate)
                    val dstSamplesForChunk = (dstEnd - dstStart).toInt()

                    if (dstSamplesForChunk > 0) {
                        val outBytes = ByteArray(dstSamplesForChunk * 2)
                        val outBuf = ByteBuffer.wrap(outBytes).order(ByteOrder.LITTLE_ENDIAN)

                        for (i in 0 until dstSamplesForChunk) {
                            val globalDstSample = dstStart + i
                            val srcPos = (globalDstSample.toDouble() * srcRate / dstRate - srcSampleOffset).toInt()
                                .coerceIn(0, samplesInChunk - 1)

                            // Read sample, convert to mono by averaging channels
                            var sum = 0L
                            for (c in 0 until srcChannels) {
                                val bytePos = (srcPos * srcChannels + c) * 2
                                if (bytePos + 1 < bytesRead) {
                                    sum += srcBuf.getShort(bytePos).toLong()
                                }
                            }
                            outBuf.putShort((sum / srcChannels).toShort())
                        }

                        raf.write(outBytes)
                        dstSampleWritten += dstSamplesForChunk
                    }

                    srcSampleOffset = chunkEndSrcSample
                }
            } finally {
                fis.close()
            }

            // Fix WAV header with actual data size
            val actualDataSize = (dstSampleWritten * 2).toInt()
            raf.seek(4)
            raf.writeIntLE(36 + actualDataSize)
            raf.seek(40)
            raf.writeIntLE(actualDataSize)

        } finally {
            raf.close()
        }
    }

    private fun writeWavHeader(raf: RandomAccessFile, sampleRate: Int, channels: Int, dataSize: Int) {
        val bitsPerSample = 16
        val byteRate = sampleRate * channels * bitsPerSample / 8
        val blockAlign = channels * bitsPerSample / 8

        val header = ByteBuffer.allocate(44).order(ByteOrder.LITTLE_ENDIAN)
        header.put("RIFF".toByteArray())
        header.putInt(36 + dataSize)
        header.put("WAVE".toByteArray())
        header.put("fmt ".toByteArray())
        header.putInt(16)
        header.putShort(1) // PCM
        header.putShort(channels.toShort())
        header.putInt(sampleRate)
        header.putInt(byteRate)
        header.putShort(blockAlign.toShort())
        header.putShort(bitsPerSample.toShort())
        header.put("data".toByteArray())
        header.putInt(dataSize)

        raf.write(header.array())
    }

    private fun RandomAccessFile.writeIntLE(value: Int) {
        val buf = ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN)
        buf.putInt(value)
        write(buf.array())
    }

    private fun remuxToMp4(inputPath: String, outputPath: String) {
        val extractor = MediaExtractor()
        extractor.setDataSource(inputPath)

        val muxer = android.media.MediaMuxer(outputPath, android.media.MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        val trackMap = mutableMapOf<Int, Int>()

        for (i in 0 until extractor.trackCount) {
            val format = extractor.getTrackFormat(i)
            val newTrackIndex = muxer.addTrack(format)
            trackMap[i] = newTrackIndex
        }

        muxer.start()
        val buffer = ByteBuffer.allocate(1024 * 1024)
        val bufferInfo = MediaCodec.BufferInfo()

        for ((srcTrack, dstTrack) in trackMap) {
            extractor.selectTrack(srcTrack)
            while (true) {
                val sampleSize = extractor.readSampleData(buffer, 0)
                if (sampleSize < 0) break
                bufferInfo.offset = 0
                bufferInfo.size = sampleSize
                bufferInfo.presentationTimeUs = extractor.sampleTime
                bufferInfo.flags = extractor.sampleFlags
                muxer.writeSampleData(dstTrack, buffer, bufferInfo)
                extractor.advance()
            }
            extractor.unselectTrack(srcTrack)
        }

        muxer.stop()
        muxer.release()
        extractor.release()

        File(inputPath).delete()
    }

}
