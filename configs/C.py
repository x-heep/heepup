# Config C: config B with cv32e40px and the XPULP extensions enabled.
from pathlib import Path

from load_config import load_cfg_file
from cpu.cv32e40px import cv32e40px

CONFIG_B = Path(__file__).resolve().parent / "B.py"


def config():
    system = load_cfg_file(CONFIG_B)
    system.set_cpu(cv32e40px(corev_pulp=True))
    return system
