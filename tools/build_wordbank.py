#!/usr/bin/env python3
"""
Build wordbank.json from Oxford 5000 + ECDICT data sources.

Usage:
    python3 tools/build_wordbank.py

Downloads:
    - Oxford 5000 word list (JSON, ~8MB) from GitHub
    - ECDICT dictionary (CSV, ~65MB) from GitHub

Output:
    - assets/data/wordbank.json (~1.5MB, 7000 words)
"""

import csv
import json
import os
import sys
import urllib.request
import subprocess

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
OUTPUT_DIR = os.path.join(PROJECT_DIR, "assets", "data")
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "wordbank.json")

CACHE_DIR = os.path.join(SCRIPT_DIR, ".cache")

OXFORD_URL = "https://raw.githubusercontent.com/tyypgzl/Oxford-5000-words/main/full-word.json"
ECDICT_URL = "https://raw.githubusercontent.com/skywind3000/ECDICT/master/ecdict.csv"

TARGET_TOTAL = 7000


def download_file(url, local_path, description="file"):
    """Download a file, using gh CLI as fallback if direct download fails."""
    if os.path.exists(local_path):
        size = os.path.getsize(local_path)
        if size > 0:
            print(f"  [cached] {description} ({size:,} bytes)")
            return True

    os.makedirs(os.path.dirname(local_path), exist_ok=True)

    # Try gh CLI first (works better in China)
    if "raw.githubusercontent.com" in url:
        parts = url.replace("https://raw.githubusercontent.com/", "").split("/")
        owner, repo = parts[0], parts[1]
        file_path = "/".join(parts[3:])
        gh_cmd = f'gh api repos/{owner}/{repo}/contents/{file_path} -H "Accept: application/vnd.github.raw" --method GET'
        print(f"  Downloading {description} via gh CLI...")
        try:
            result = subprocess.run(
                gh_cmd, shell=True, capture_output=True, timeout=600
            )
            if result.returncode == 0 and len(result.stdout) > 100:
                with open(local_path, "wb") as f:
                    f.write(result.stdout)
                print(f"  Downloaded {len(result.stdout):,} bytes")
                return True
        except Exception as e:
            print(f"  gh CLI failed: {e}")

    # Fallback to urllib
    print(f"  Downloading {description} via urllib...")
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=600) as resp:
            data = resp.read()
            with open(local_path, "wb") as f:
                f.write(data)
            print(f"  Downloaded {len(data):,} bytes")
            return True
    except Exception as e:
        print(f"  urllib failed: {e}")

    return False


def load_oxford(path):
    """Load Oxford 5000 word list and normalize to a dict keyed by lowercase word."""
    print("Loading Oxford 5000...")
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    words = {}
    for entry in data:
        val = entry.get("value", {})
        word = val.get("word", "").strip().lower()
        if not word:
            continue

        level = val.get("level", "")
        phonetics = val.get("phonetics", {})
        us_audio = val.get("us", {}).get("mp3", "")
        uk_audio = val.get("uk", {}).get("mp3", "")
        examples = val.get("examples", [])

        examples = [ex.strip() for ex in examples if ex.strip()][:3]
        phonetic = phonetics.get("us", "") or phonetics.get("uk", "")
        audio_url = us_audio or uk_audio
        pos = val.get("type", "")

        if word not in words:
            words[word] = {
                "w": word,
                "l": level,
                "p": phonetic,
                "au": audio_url,
                "pos": pos,
                "ex": examples,
                "t": "",
            }
        else:
            existing = words[word]
            for ex in examples:
                if ex not in existing["ex"] and len(existing["ex"]) < 5:
                    existing["ex"].append(ex)

    print(f"  Loaded {len(words)} unique words")
    return words


def load_ecdict(path):
    """Load ECDICT CSV into a dict keyed by lowercase word."""
    print("Loading ECDICT (this may take a moment for 65MB CSV)...")

    ecdict = {}
    with open(path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            word = row.get("word", "").strip().lower()
            if not word or not word[0].isalpha() or len(word) < 2:
                continue

            translation = row.get("translation", "").strip()
            if not translation:
                continue

            phonetic = row.get("phonetic", "").strip()
            definition = row.get("definition", "").strip()
            bnc = row.get("bnc", "0").strip()
            frq = row.get("frq", "0").strip()
            tag = row.get("tag", "").strip()
            pos = row.get("pos", "").strip()

            try:
                bnc = int(bnc) if bnc else 0
                frq = int(frq) if frq else 0
            except ValueError:
                bnc = 0
                frq = 0

            trans_lines = translation.replace("\\n", "\n").split("\n")
            clean_trans = "；".join(
                line.strip() for line in trans_lines[:2] if line.strip()
            )
            if len(clean_trans) > 80:
                clean_trans = clean_trans[:80] + "..."

            ecdict[word] = {
                "translation": clean_trans,
                "phonetic": phonetic,
                "definition": definition,
                "bnc": bnc,
                "frq": frq,
                "tag": tag,
                "pos": pos,
            }

    print(f"  Loaded {len(ecdict)} entries with Chinese translations")
    return ecdict


def merge_data(oxford_words, ecdict):
    """Merge Oxford 5000 with ECDICT Chinese translations,
    then fill remaining slots from ECDICT by frequency."""
    print("Merging data...")

    matched = 0
    for word, data in oxford_words.items():
        if word in ecdict:
            data["t"] = ecdict[word]["translation"]
            if not data["p"] and ecdict[word]["phonetic"]:
                data["p"] = f'/{ecdict[word]["phonetic"]}/'
            matched += 1

    print(f"  Oxford words matched with ECDICT translations: {matched}/{len(oxford_words)}")

    result = list(oxford_words.values())
    oxford_set = set(oxford_words.keys())

    remaining = TARGET_TOTAL - len(result)
    if remaining > 0:
        print(f"  Need {remaining} more words from ECDICT...")

        candidates = []
        for word, data in ecdict.items():
            if word in oxford_set:
                continue
            if not data["translation"]:
                continue
            if data["bnc"] <= 0:
                continue
            if len(word) < 3 or " " in word or "-" in word:
                continue
            candidates.append((word, data))

        candidates.sort(key=lambda x: x[1]["bnc"])

        added = 0
        for word, data in candidates:
            if added >= remaining:
                break
            phonetic = data["phonetic"]
            if phonetic and not phonetic.startswith("/"):
                phonetic = f"/{phonetic}/"

            result.append({
                "w": word,
                "l": "EXT",
                "p": phonetic,
                "au": "",
                "pos": data["pos"].split("/")[0] if data["pos"] else "",
                "ex": [],
                "t": data["translation"],
            })
            added += 1

        print(f"  Added {added} high-frequency words from ECDICT")

    return result


def sort_and_index(words):
    """Sort words by CEFR level then alphabetically, and assign indices."""
    level_order = {"A1": 0, "A2": 1, "B1": 2, "B2": 3, "C1": 4, "EXT": 5, "": 6}
    words.sort(key=lambda w: (level_order.get(w["l"], 6), w["w"]))
    words = words[:TARGET_TOTAL]
    for i, word in enumerate(words):
        word["i"] = i
    return words


def build_stats(words):
    """Print level statistics."""
    from collections import Counter
    levels = Counter(w["l"] for w in words)
    print(f"\nFinal word count: {len(words)}")
    print("Level distribution:")
    for level in ["A1", "A2", "B1", "B2", "C1", "EXT"]:
        print(f"  {level}: {levels.get(level, 0)} words")

    with_trans = sum(1 for w in words if w["t"])
    with_audio = sum(1 for w in words if w["au"])
    with_examples = sum(1 for w in words if w["ex"])
    print(f"\nWith Chinese translation: {with_trans}/{len(words)}")
    print(f"With audio URL: {with_audio}/{len(words)}")
    print(f"With examples: {with_examples}/{len(words)}")


def main():
    print("=" * 60)
    print("Building wordbank.json (Oxford 5000 + ECDICT)")
    print("=" * 60)

    os.makedirs(CACHE_DIR, exist_ok=True)
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    oxford_path = os.path.join(CACHE_DIR, "oxford5000.json")
    ecdict_path = os.path.join(CACHE_DIR, "ecdict.csv")

    print("\n[1/5] Downloading Oxford 5000...")
    if not download_file(OXFORD_URL, oxford_path, "Oxford 5000 JSON"):
        print("ERROR: Failed to download Oxford 5000. Check network.")
        sys.exit(1)

    print("\n[2/5] Downloading ECDICT...")
    if not download_file(ECDICT_URL, ecdict_path, "ECDICT CSV (~65MB)"):
        print("ERROR: Failed to download ECDICT. Check network.")
        print("You can manually download from: https://github.com/skywind3000/ECDICT")
        print(f"Place the ecdict.csv file at: {ecdict_path}")
        sys.exit(1)

    print("\n[3/5] Parsing data sources...")
    oxford_words = load_oxford(oxford_path)
    ecdict = load_ecdict(ecdict_path)

    print("\n[4/5] Merging and building wordbank...")
    merged = merge_data(oxford_words, ecdict)
    sorted_words = sort_and_index(merged)
    build_stats(sorted_words)

    print(f"\n[5/5] Writing {OUTPUT_FILE}...")
    output = {
        "version": 1,
        "totalWords": len(sorted_words),
        "words": sorted_words,
    }

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, separators=(",", ":"))

    file_size = os.path.getsize(OUTPUT_FILE)
    print(f"  Written {file_size:,} bytes ({file_size / 1024 / 1024:.1f} MB)")
    print(f"\nDone! Wordbank saved to: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
