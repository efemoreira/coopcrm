#!/usr/bin/env python3
"""Fix escape sequences: \\${ -> ${ (string interpolation), keep R\\$ as literal currency."""
import os
import re

BASE = "/Users/felipemoreira/development/opensquads/agentcode/opensquad/squads/software-factory/output/2026-04-05-223053/coopcrm/lib"

files_to_fix = [
    "features/oportunidades/presentation/widgets/oportunidade_card.dart",
    "features/oportunidades/presentation/pages/oportunidade_detail_page.dart",
    "features/oportunidades/presentation/pages/feed_page.dart",
    "features/cotas/presentation/pages/cotas_page.dart",
]

for rel in files_to_fix:
    full = os.path.join(BASE, rel)
    with open(full, "r") as f:
        content = f.read()
    
    # Replace \${ with ${ (interpolation, but not after R)
    # Keep "R\$" as R$ (literal currency symbol)
    fixed = re.sub(r'(?<!R)\\\${', '${', content)
    
    with open(full, "w") as f:
        f.write(fixed)
    print(f"FIXED: {rel}")

print("ESCAPE FIX DONE")
