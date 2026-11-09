# Solution of exercises/B.py: config A with cv32e40p, N-to-M bus,
# 2 contiguous 32 KiB banks + 4 interleaved 16 KiB banks.
from pathlib import Path

from load_config import load_cfg_file
from bus_type import BusType
from cpu.cv32e40p import cv32e40p
from memory_ss.memory_ss import MemorySS
from memory_ss.linker_section import LinkerSection

CONFIG_A = Path(__file__).resolve().parents[2] / "configs/A.py"


def config():
    system = load_cfg_file(CONFIG_A)

    system.set_bus_type(BusType.NtoM)

    system.set_cpu(cv32e40p())

    memory_ss = MemorySS()
    memory_ss.add_ram_banks([32] * 2)
    memory_ss.add_ram_banks_il(4, 16, "data_interleaved")
    memory_ss.add_linker_section(LinkerSection.by_size("code", 0, 0x8000))
    memory_ss.add_linker_section(LinkerSection("data", 0x8000, None))
    system.set_memory_ss(memory_ss)

    return system
