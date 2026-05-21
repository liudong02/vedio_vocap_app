#!/usr/bin/env python3
"""
Video subtitle generator using OpenAI Whisper.

Usage:
    python generate_subtitles.py <video_file>
    python generate_subtitles.py <video_file> --model medium
    python generate_subtitles.py <directory>          # batch process all videos

Output:
    Creates a .srt file with the same name next to the video.
    e.g. movie.mp4 -> movie.srt

Requirements:
    pip install openai-whisper
    brew install ffmpeg
"""

import argparse
import sys
from pathlib import Path

VIDEO_EXTENSIONS = {".mp4", ".mkv", ".avi", ".mov", ".webm", ".flv", ".wmv", ".m4v"}


def generate_srt(video_path: Path, model_name: str = "base", language: str = "en") -> Path:
    """Generate .srt subtitle file from video using Whisper."""
    import whisper

    srt_path = video_path.with_suffix(".srt")

    print(f"Loading Whisper model '{model_name}'...")
    model = whisper.load_model(model_name)

    print(f"Transcribing: {video_path.name}")
    result = model.transcribe(
        str(video_path),
        language=language,
        verbose=False,
    )

    segments = result["segments"]
    print(f"  Found {len(segments)} segments")

    with open(srt_path, "w", encoding="utf-8") as f:
        for i, seg in enumerate(segments, 1):
            start = format_timestamp(seg["start"])
            end = format_timestamp(seg["end"])
            text = seg["text"].strip()
            f.write(f"{i}\n{start} --> {end}\n{text}\n\n")

    print(f"  Output: {srt_path.name}")
    return srt_path


def format_timestamp(seconds: float) -> str:
    """Convert seconds to SRT timestamp format: HH:MM:SS,mmm"""
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = int(seconds % 60)
    ms = int((seconds % 1) * 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def find_videos(path: Path) -> list[Path]:
    """Find all video files in a directory."""
    if path.is_file():
        if path.suffix.lower() in VIDEO_EXTENSIONS:
            return [path]
        else:
            print(f"Error: {path} is not a supported video format")
            sys.exit(1)

    videos = sorted(p for p in path.iterdir() if p.suffix.lower() in VIDEO_EXTENSIONS)
    if not videos:
        print(f"No video files found in {path}")
        sys.exit(1)
    return videos


def main():
    parser = argparse.ArgumentParser(
        description="Generate .srt subtitles from video using Whisper"
    )
    parser.add_argument("input", type=Path, help="Video file or directory of videos")
    parser.add_argument(
        "--model",
        default="base",
        choices=["tiny", "base", "small", "medium", "large"],
        help="Whisper model size (default: base). Larger = more accurate but slower",
    )
    parser.add_argument(
        "--language", default="en", help="Language code (default: en)"
    )
    parser.add_argument(
        "--overwrite", action="store_true", help="Overwrite existing .srt files"
    )
    args = parser.parse_args()

    if not args.input.exists():
        print(f"Error: {args.input} does not exist")
        sys.exit(1)

    videos = find_videos(args.input)
    print(f"Found {len(videos)} video(s) to process\n")

    for video in videos:
        srt_path = video.with_suffix(".srt")
        if srt_path.exists() and not args.overwrite:
            print(f"Skipping {video.name} (.srt already exists, use --overwrite)")
            continue
        generate_srt(video, model_name=args.model, language=args.language)
        print()

    print("Done!")


if __name__ == "__main__":
    main()
