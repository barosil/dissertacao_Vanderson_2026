#!/usr/bin/env python3
"""
Script para redimensionar imagens para diferentes propósitos.

Propósitos:
- EPS para impressão: 600 DPI, 180mm largura
- Web (fullwidth): 150 DPI, largura completa
- Web (halfwidth): 150 DPI, meia largura

Uso:
    python resize_images.py <input_dir> <output_dir> --purpose <propósito>
    python resize_images.py content/00_images output/processed --purpose print
"""

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Erro: Pillow não está instalado. Execute: pip install Pillow")
    sys.exit(1)


# Configurações de redimensionamento
PURPOSES = {
    "print": {
        "dpi": 600,
        "width_mm": 180,
        "format": "eps",
        "description": "Impressão (600 DPI, 180mm)",
    },
    "web-full": {
        "dpi": 150,
        "width_px": 1200,
        "format": "webp",
        "description": "Web largura completa (150 DPI)",
    },
    "web-half": {
        "dpi": 150,
        "width_px": 600,
        "format": "webp",
        "description": "Web meia largura (150 DPI)",
    },
    "web-png-full": {
        "dpi": 150,
        "width_px": 1200,
        "format": "png",
        "description": "Web PNG largura completa (150 DPI)",
    },
    "web-png-half": {
        "dpi": 150,
        "width_px": 600,
        "format": "png",
        "description": "Web PNG meia largura (150 DPI)",
    },
}


def mm_to_pixels(mm: float, dpi: int) -> int:
    """
    Converte milímetros para pixels dado um DPI.

    Args:
        mm: Dimensão em milímetros
        dpi: Dots per inch (pontos por polegada)

    Returns:
        Dimensão em pixels
    """
    inches = mm / 25.4
    return int(inches * dpi)


def resize_image(input_path: Path, output_path: Path, purpose: str) -> bool:
    """
    Redimensiona uma imagem de acordo com o propósito especificado.

    Args:
        input_path: Caminho da imagem de entrada
        output_path: Caminho da imagem de saída
        purpose: Propósito do redimensionamento

    Returns:
        True se o redimensionamento foi bem-sucedido, False caso contrário
    """
    try:
        config = PURPOSES[purpose]

        # Abrir imagem
        img = Image.open(input_path)
        original_size = img.size

        # Calcular novo tamanho
        if "width_mm" in config:
            # Para impressão (baseado em mm e DPI)
            new_width = mm_to_pixels(config["width_mm"], config["dpi"])
            aspect_ratio = img.size[1] / img.size[0]
            new_height = int(new_width * aspect_ratio)
        else:
            # Para web (baseado em pixels)
            new_width = config["width_px"]
            aspect_ratio = img.size[1] / img.size[0]
            new_height = int(new_width * aspect_ratio)

        new_size = (new_width, new_height)

        # Redimensionar imagem com alta qualidade
        img_resized = img.resize(new_size, Image.Resampling.LANCZOS)

        # Converter para RGB se necessário
        output_format = config["format"].lower()
        if output_format in ["eps", "jpg", "jpeg"] and img_resized.mode in [
            "RGBA",
            "LA",
            "P",
        ]:
            background = Image.new("RGB", img_resized.size, (255, 255, 255))
            if img_resized.mode == "P":
                img_resized = img_resized.convert("RGBA")
            if img_resized.mode in ["RGBA", "LA"]:
                background.paste(img_resized, mask=img_resized.split()[-1])
                img_resized = background

        # Criar diretório de saída se não existir
        output_path.parent.mkdir(parents=True, exist_ok=True)

        # Salvar com DPI correto
        dpi_tuple = (config["dpi"], config["dpi"])

        if output_format == "eps":
            img_resized.save(output_path, "EPS", dpi=dpi_tuple)
        elif output_format == "webp":
            img_resized.save(output_path, "WEBP", quality=95, dpi=dpi_tuple)
        elif output_format == "png":
            img_resized.save(output_path, "PNG", dpi=dpi_tuple, optimize=True)
        else:
            img_resized.save(output_path, output_format.upper(), dpi=dpi_tuple)

        print(
            f"✓ {input_path.name}: {original_size} → {new_size} ({config['dpi']} DPI)"
        )
        return True

    except Exception as e:
        print(f"✗ Erro ao redimensionar {input_path.name}: {str(e)}")
        return False


def find_images(input_dir: Path) -> list:
    """Encontra todas as imagens em um diretório."""
    extensions = [".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp", ".tiff"]
    images = []
    for ext in extensions:
        images.extend(input_dir.rglob(f"*{ext}"))
        images.extend(input_dir.rglob(f"*{ext.upper()}"))
    return sorted(set(images))


def main():
    parser = argparse.ArgumentParser(
        description="Redimensionar imagens para diferentes propósitos",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Propósitos disponíveis:
  print         - Impressão: 600 DPI, 180mm largura (EPS)
  web-full      - Web: 150 DPI, 1200px largura (WebP)
  web-half      - Web: 150 DPI, 600px largura (WebP)
  web-png-full  - Web: 150 DPI, 1200px largura (PNG)
  web-png-half  - Web: 150 DPI, 600px largura (PNG)

Exemplos:
  python resize_images.py images/ output/ --purpose print
  python resize_images.py images/ output/ --purpose web-full
        """,
    )
    parser.add_argument(
        "input_dir", type=str, help="Diretório de entrada contendo as imagens"
    )
    parser.add_argument(
        "output_dir",
        type=str,
        help="Diretório de saída para as imagens redimensionadas",
    )
    parser.add_argument(
        "--purpose",
        "-p",
        type=str,
        required=True,
        choices=list(PURPOSES.keys()),
        help="Propósito do redimensionamento",
    )

    args = parser.parse_args()

    # Validar diretórios
    input_dir = Path(args.input_dir)
    if not input_dir.exists():
        print(f"Erro: Diretório de entrada não existe: {input_dir}")
        sys.exit(1)

    output_dir = Path(args.output_dir)
    purpose = args.purpose

    # Mostrar configuração
    config = PURPOSES[purpose]
    print(f"Configuração: {config['description']}")
    print(f"Formato de saída: {config['format'].upper()}\n")

    # Encontrar imagens
    print(f"Buscando imagens em: {input_dir}")
    images = find_images(input_dir)

    if not images:
        print("Nenhuma imagem encontrada!")
        sys.exit(0)

    print(f"Encontradas {len(images)} imagem(ns)\n")

    # Redimensionar imagens
    success_count = 0
    for img_path in images:
        # Manter estrutura de diretórios
        relative_path = img_path.relative_to(input_dir)
        output_path = (
            output_dir / purpose / relative_path.with_suffix(f".{config['format']}")
        )

        if resize_image(img_path, output_path, purpose):
            success_count += 1

    # Resumo
    print(f"\n{'=' * 60}")
    print("Redimensionamento concluído!")
    print(f"Sucesso: {success_count}/{len(images)}")
    print(f"Imagens salvas em: {output_dir / purpose}")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
