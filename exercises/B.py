# Exercise: build config B on top of config A.
# Target: cv32e40p, N-to-M bus, 2 contiguous 32 KiB banks + 4 interleaved 16 KiB banks.
# Look at ../configs/A.py for the API. Solution: ../configs/B.py
from pathlib import Path

from load_config import load_cfg_file
from bus_type import BusType
from cpu.cv32e40p import cv32e40p
from memory_ss.memory_ss import MemorySS
from memory_ss.linker_section import LinkerSection

CONFIG_A = Path(__file__).resolve().parents[1] / "configs/A.py"


def config():
    system = load_cfg_file(CONFIG_A)

    # TODO 1: set the bus type to N-to-M

    # TODO 2: set the CPU to cv32e40p

    # TODO 3: new memory subsystem
    #   - 2 contiguous banks of 32 KiB
    #   - 4 interleaved banks of 16 KiB, group "data_interleaved"
    #   - linker sections: "code" in the first 0x8000 bytes, "data" from 0x8000 on

    return system
