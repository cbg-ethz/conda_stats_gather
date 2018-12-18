#!/usr/bin/env python3
import pandas as pd

import seaborn as sns
import matplotlib.pyplot as plt


sns.set_context('talk')


def plot(df_long, value_var, ylabel, fname):
    tool_num = df_long['variable'].unique().size
    pal = sns.color_palette('muted', n_colors=tool_num)

    g = sns.FacetGrid(
        df_long, row='group', hue='variable',
        sharey=False, legend_out=True,
        height=7, aspect=2,
        palette=pal)
    g.map_dataframe(
        sns.lineplot, x='timestamp', y=value_var)

    # g.add_legend()
    g.set_axis_labels('Date', ylabel)
    #g.set_xticklabels(rotation=45)  # https://github.com/mwaskom/seaborn/issues/1598
    plt.xticks(rotation=45, ha='right')

    for ax in g.axes.flatten():
        ax.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0)

    g.savefig(fname)


def totals(df_long):
    plot(df_long, 'value', 'Total downloads', 'overview_totals.pdf')


def diffs(df_long):
    df_long['diff'] = df_long.groupby('variable')['value'].diff()

    plot(df_long, 'diff', 'New downloads', 'overview_diffs.pdf')


def main():
    df = pd.read_csv('downloads.csv')
    df['timestamp'] = pd.to_datetime(df['timestamp'])

    df_long = pd.melt(df, id_vars='timestamp')
    grouping = {
        'in-house': ['ngshmmalign', 'shorah', 'haploclique', 'indelfixer', 'consensusfixer', 'smallgenomeutilities'],
        'other': ['lofreq', 'mvicuna', 'prinseq', 'mafft', 'bwa', 'samtools', 'picard', 'snakemake', 'savage']
    }
    g2 = {t: k for k, v in grouping.items() for t in v}

    df_long['variable'].map(lambda x: g2[x])
    df_long['group'] = df_long['variable'].map(lambda x: g2[x])

    totals(df_long)
    diffs(df_long)


if __name__ == '__main__':
    main()
