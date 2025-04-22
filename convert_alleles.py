#!/usr/bin/env python3

import pysam
import os
import argparse
import logging
import pandas as pd

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s", handlers=[logging.FileHandler("script.log"),logging.StreamHandler()])

def load_reference(fasta_path):
    try:
        return pysam.FastaFile(fasta_path)
    except Exception as e:
        logging.error(f"Ошибка при открытии FASTA: {fasta_path}: {e}.")
        return None

def main(args):
    df = pd.read_csv(args.input, sep='\t')
    logging.info(f"Начало обработки файла: {args.input}.")
    references = {}


    required_columns = ['#CHROM', 'POS', 'ID', 'allele1', 'allele2']
    if not all(col in df.columns for col in required_columns):
        logging.error(f"Входной файл не соответствует формату и должен содержать следующие колонки: {', '.join(required_columns)}.")
        return

    output_data = []
    for _, row in df.iterrows():
        chrom = row['#CHROM']
        pos = int(row['POS'])

        if chrom not in references:
            fasta_file = os.path.join(args.reference, f"{chrom}.fa")
            if not os.path.exists(fasta_file):
                logging.error(f"Файл не найден: {fasta_file}.")
                continue
            references[chrom] = load_reference(fasta_file)
            if references[chrom] is None:
                continue

        ref_base = references[chrom].fetch(chrom, pos - 1, pos).upper()
        allele1 = row['allele1'].upper()
        allele2 = row['allele2'].upper()
        if allele1 == ref_base:
            ref, alt = allele1, allele2
        elif allele2 == ref_base:
            ref, alt = allele2, allele1
        else:
            logging.warning(f"Ни один аллель не совпадает с референсом: {chrom}:{pos}. Референс={ref_base}, аллели={allele1}/{allele2}.")
            continue

        output_data.append({
            '#CHROM': chrom,
            'POS': pos,
            'ID': row['ID'],
            'REF': ref,
            'ALT': alt
        })

    output_df = pd.DataFrame(output_data)
    output_df.to_csv(args.output, sep='\t', index=False)

    logging.info(f"Результат сохранён в файл: {args.output}.")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Выявление референсного и альтернативного аллеля на основе референсной геномной последовательности.')
    parser.add_argument('--input', required=True, help='входной TSV-файл с колонками: #CHROM, POS, ID, allele1, allele2')
    parser.add_argument('--output', required=True, help='выходной TSV-файл')
    parser.add_argument('--reference', required=True, help='путь к папке с FASTA-файлами всех хромосом (chr[1-22,M,X,Y].fa[.fai])')
    args = parser.parse_args()
    main(args)