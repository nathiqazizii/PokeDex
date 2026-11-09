#!/usr/bin/env python3
"""Menambal proyek Android hasil `flutter create` sesuai kebutuhan PokéDex.

Dijalankan dari root proyek, setelah `flutter create --platforms=android .`:
  1. AndroidManifest.xml: izin INTERNET, POST_NOTIFICATIONS, lokasi; label aplikasi.
  2. build.gradle(.kts): core library desugaring (dibutuhkan flutter_local_notifications).

Skrip ini aman dijalankan berulang kali (idempoten).
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / "android" / "app"
MANIFEST = APP / "src" / "main" / "AndroidManifest.xml"
DESUGAR = "com.android.tools:desugar_jdk_libs:2.1.4"

PERMISSIONS = [
    "android.permission.INTERNET",
    "android.permission.POST_NOTIFICATIONS",
    "android.permission.ACCESS_FINE_LOCATION",
    "android.permission.ACCESS_COARSE_LOCATION",
]


def patch_manifest() -> None:
    text = MANIFEST.read_text(encoding="utf-8")

    missing = [p for p in PERMISSIONS if f'android:name="{p}"' not in text]
    if missing:
        lines = "".join(f'    <uses-permission android:name="{p}"/>\n' for p in missing)
        if "<application" not in text:
            sys.exit("ERROR: <application> tidak ditemukan di AndroidManifest.xml")
        text = text.replace("<application", lines + "    <application", 1)

    text = re.sub(r'android:label="[^"]*"', 'android:label="PokéDex"', text, count=1)
    MANIFEST.write_text(text, encoding="utf-8")
    print(f"OK  manifest: izin ditambahkan {len(missing)}, label diatur")


def patch_gradle_kts(path: Path) -> None:
    text = path.read_text(encoding="utf-8")

    if "isCoreLibraryDesugaringEnabled" not in text:
        new, n = re.subn(
            r"(compileOptions\s*\{)",
            r"\1\n        isCoreLibraryDesugaringEnabled = true",
            text,
            count=1,
        )
        if n == 0:
            sys.exit("ERROR: blok compileOptions tidak ditemukan di build.gradle.kts")
        text = new

    if "coreLibraryDesugaring(" not in text:
        if re.search(r"^dependencies\s*\{", text, flags=re.M):
            text = re.sub(
                r"^(dependencies\s*\{)",
                rf'\1\n    coreLibraryDesugaring("{DESUGAR}")',
                text,
                count=1,
                flags=re.M,
            )
        else:
            text += f'\ndependencies {{\n    coreLibraryDesugaring("{DESUGAR}")\n}}\n'

    path.write_text(text, encoding="utf-8")
    print(f"OK  {path.name}: desugaring aktif")


def patch_gradle_groovy(path: Path) -> None:
    text = path.read_text(encoding="utf-8")

    if "coreLibraryDesugaringEnabled" not in text:
        new, n = re.subn(
            r"(compileOptions\s*\{)",
            r"\1\n        coreLibraryDesugaringEnabled true",
            text,
            count=1,
        )
        if n == 0:
            sys.exit("ERROR: blok compileOptions tidak ditemukan di build.gradle")
        text = new

    if "coreLibraryDesugaring '" not in text and 'coreLibraryDesugaring "' not in text:
        if re.search(r"^dependencies\s*\{", text, flags=re.M):
            text = re.sub(
                r"^(dependencies\s*\{)",
                rf"\1\n    coreLibraryDesugaring '{DESUGAR}'",
                text,
                count=1,
                flags=re.M,
            )
        else:
            text += f"\ndependencies {{\n    coreLibraryDesugaring '{DESUGAR}'\n}}\n"

    path.write_text(text, encoding="utf-8")
    print(f"OK  {path.name}: desugaring aktif")


def main() -> None:
    if not MANIFEST.exists():
        sys.exit(
            "ERROR: folder android/ belum ada. Jalankan dulu:\n"
            "  flutter create --platforms=android --org id.ac.upnyk ."
        )

    patch_manifest()

    kts = APP / "build.gradle.kts"
    groovy = APP / "build.gradle"
    if kts.exists():
        patch_gradle_kts(kts)
    elif groovy.exists():
        patch_gradle_groovy(groovy)
    else:
        sys.exit("ERROR: build.gradle(.kts) tidak ditemukan di android/app")


if __name__ == "__main__":
    main()
