#!/usr/bin/env python3
"""Set the CoCo 3 monitor to RGB while preserving other MAME configuration."""
import argparse
from pathlib import Path
import xml.etree.ElementTree as ET


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--machine', required=True)
    parser.add_argument('--config', type=Path, required=True)
    args = parser.parse_args()
    args.config.mkdir(parents=True, exist_ok=True)
    path = args.config / (args.machine + '.cfg')
    root = ET.parse(path).getroot() if path.exists() else ET.Element('mameconfig', version='10')
    system = next((s for s in root.findall('system') if s.get('name') == args.machine), None)
    if system is None:
        system = ET.SubElement(root, 'system', name=args.machine)
    inputs = system.find('input')
    if inputs is None:
        inputs = ET.SubElement(system, 'input')
    port = next((p for p in inputs.findall('port') if p.get('tag') == ':screen_config'), None)
    if port is None:
        port = ET.SubElement(inputs, 'port')
    port.attrib.update(tag=':screen_config', type='CONFIG', mask='1', defvalue='0', value='1')
    ET.ElementTree(root).write(path, encoding='utf-8', xml_declaration=True)


if __name__ == '__main__':
    main()
