#!/usr/bin/env python3.12

"""
    Extract the text of the Urantia Papers (including footnotes) from LaTeX
    source code of The British Study Edition of the Urantia Papers available at:
        https://github.com/tigran123/urantia-study-edition
    and convert to the form suitable for training a custom OpenAI GPT.

    Author: Tigran Aivazian
    Date: April 2024
    Copyright: GPLv3
"""

import re, regex

TEXDIR: str = '../tex'
OUTPUT: str = 'The-British-Study-Edition-of-the-Urantia-Papers.txt'
HEADER: str = 'The British Study Edition of The Urantia Papers\nEdited by Tigran Aivazian\nWith study notes and bibliography\nBibles.org.uk, London, 2011.\n'
INTRO: str = """
Introduction

The purpose of the Fifth Epochal Revelation is to expand cosmic consciousness and enhance spiritual perception. The high ideals and the example of the life of Jesus are especially needed today, in the times of planetary crisis and pandemia of fear and madness, caused by intellectual ignorance and spiritual blindness.

<i>The British Study Edition of The Urantia Papers</i> has the following distinct features:

1. The present text of The Urantia Papers is based on that of the Fifth Epochal Revelation, and was revised according to the present scientific knowledge and spiritual enlightenment.

2. Study notes and textual variants are printed in the apparatus at the bottom of the page.

3. All distance and temperature measures have been converted to metric units, except where there was even the slightest potential for error, such as in the use of "Jerusem miles", which was left intact. The idiomatic expressions like "carry his pack for a mile" were also left intact, obviously. Long and hard to memorise phrases like "three hundred and forty-five thousand" have been converted to a compact form "345,000". Likewise, for phrases like "seventy-five per cent" a more compact form of "75%" was chosen. Similarly, the time designations like "fifteen minutes past four o’clock" now read "16:15".

4. Designation of the author of each paper (and Foreword) is printed in on a line by itself just before the text.

5. Paper:Section.Paragraph indicator is prefixed to the teach of each paragraph.

6. The Bibliography of the human sources used in the Revelation is printed at the end of each Paper. When it was deemed essential the reference to the source(s) was also indicated in the footnotes.

The need for the revision of the text was predicted by the Revelation itself at 101:4.2:

... within a few short years many of our statements regarding the physical sciences will stand in need of revision in consequence of additional scientific developments and new discoveries.

Well, those "few short years" have come to pass and it now devolves upon us --- its students and guardians --- to revise, expand and fearlessly continue the living stream of the Fifth Epochal Revelation: "My Father worketh hitherto, and I work (John 5:17).

Realizing the great importance of this text, a group of volunteers and I have carefully preserved the original First Edition (1955) of the Urantia Papers, known at the time as <i>The Urantia Book,</i> and made it available on my website in both electronic and printed forms: http://www.bibles.org.uk/guardian-plates.html

For deriving the etymology of the words coined in the text, I acknowledge the use of the notes by Dr Chris Halvorson.

I am grateful to my friends Jim George, Mitch Austin and Sergey Prokopov for their helpful suggestions and comments, some of which have been incorporated into the study notes of the present edition.

I would like to thank Irina Chernova for creating illustrations for this edition. For information on the human sources, upon which this Revelation is based, I am indebted almost entirely to the outstanding research work by Matthew Block as published on his website: https://urantiabooksources.com/

A few of the sources related to the material of the Revelation related to the physical sciences have been discovered by myself independently of Matthew's research.

Last but not least I am deeply grateful to Troy R. Bishop, whom I am honoured to call my mentor and dear friend.

Tigran Aivazian
London, England, 13th July 2011.
"""


def process_lines(paper: str, linesin: list[str]) -> list[str]:
    linesout = []

    section = 1
    for line in linesin:
        if ignore_line_re.match(line):
            continue
        elif (match := upaper_re.match(line)):
            if paper == '0':
                line = f"\n\n{match.group(2).replace(r'\hyp{}','-')}\n"
            else:
                line = f"\n\nPaper {match.group(1)}: {match.group(2).replace(r'\hyp{}','-')}\n"
        elif (match := author_re.match(line)):
            line = f'Author: {match.group(1)}\n\n'
        elif (match := usection_re.match(line)):
            if paper == '0':
                if section == 13:
                    line = f"\nForeword, {match.group(1)}.\n"
                else:
                    line = f"\nForeword, section {section}: {match.group(1).replace(r'\hyp{}','-')}.\n"
            else:
                line = f"\nPaper {paper}, section {section}: {match.group(1).replace(r'\hyp{}','-').replace('\\\\', '. ')}.\n"
            section += 1
        elif (match := vs_re.match(line)):
            line = f"{paper}:{match.group(2)}.{match.group(3)} {match.group(4)}".replace(r'\hyp{}','-') \
              .replace(r'\bibnobreakspace ', ' ').replace(r'\bibnobreakspace', ' ').replace('~', ' ').replace(r'\pc ', ' ').replace("''", '"') \
              .replace('``', '"').replace(r"\'", '').replace(r'\,', ' ').replace(r'\separatorline', '*****').replace(r'\separatorshort', '***')
            line = strip_macro_name_re.sub(lambda m: m.group(1), line)
            line = regex.sub(r'\\textcolour{((?:[^{}]+|\{(?1)\})*+)}', lambda m: match.group(1), line)
            line = bibemph_re.sub(lambda m: f'<i>{m.group(1)}</i>', line)
            line = bibref_re.sub(lambda m: f'{m.group(1)}:{m.group(2)}.{m.group(3)}', line)
            line = fnst_re.sub(lambda m: f' [Footnote: {m.group(1)}]', line)
            line = ublistelem_re.sub(lambda m: m.group(1), line)
            line = tunemarkup_pg_re.sub('', line)
            line = tunemarkup_pictures_re.sub('', line) + '\n'
        else:
            line = line.replace('~', ' ').replace("''", '"').replace('``', '"').replace(r"\'", '').replace(r'\,', ' ').replace('\\&\\', '&').replace(r'\hyp{}','-')
        line = compact_space_re.sub(' ', line)
        linesout.append(line)
    return linesout


if __name__ == "__main__":
    # compile all regular expressions only once
    ignore_line_re = re.compile(r'^(?:\\begin{quote}|\\end{quote}|\\uminitoc{.*}|\\vsetoff|\\quizlink|\\tunemarkuptwo{nobiblio}{}{%|}$)')
    upaper_re = re.compile(r'^\\upaper{(\d+)}{(.*)}')
    usection_re = re.compile(r'^\\usection{(.*)}')
    author_re = re.compile(r'^\\author{(.*)}')
    hyp_re = re.compile(r'^\\hyp{}')
    bibemph_re = re.compile(r'\\(?:bibemph|textit|bibexpl){([^}]+?)}')
    strip_macro_name_re = re.compile(r'\\(?:textsc|texttt|textgreek|textheb|textarm|textchinese){([^}]+?)}')
    bibref_re = re.compile(r'\\bibref\[(\d+):(\d+)\.(\d+)\]{p0*\1 (\d+):(\d+)\}')
    fnst_re = re.compile(r'\\fnst{([^}]+)}')
    vs_re = re.compile(r'^\\vs p(0*\d*) (\d+):(\d+) (.*)')
    ublistelem_re = re.compile(r'\\ublistelem{([^}]+?)}')
    tunemarkup_pg_re = re.compile(r'\\tunemarkup{pg[^}]+?}{[^}]+?}')
    tunemarkup_pictures_re = re.compile(r'\\tunemarkup{(?:private|pictures)}{.*}$')
    compact_space_re = re.compile(' +')

    output_lines = []
    for i in range(197):
        pXXX = 'p{0:03}'.format(i)
        infile = TEXDIR + '/' + pXXX + '.tex'
        with open(infile) as fin:
            output_lines += process_lines(str(i), fin.readlines())

    with open(OUTPUT, 'w') as fout:
        fout.write(HEADER)
        fout.write(INTRO)
        fout.writelines(output_lines)
