#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Directory.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Directory is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Directory. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Directory, please visit:
# https://github.com/openflighthpc/flight-directory
#==============================================================================

import click
from terminaltables import DoubleTable
import textwrap
import subprocess

def line_wrap(text):
    return textwrap.fill(
        text,
        width=80,
        replace_whitespace=False,
        break_long_words=False,
        break_on_hyphens=False,
    )


def join_lines(*parts):
    return '\n'.join(parts)


def info(text):
    return _colour_text(text, 'yellow')


def success(text):
    return _colour_text(text, 'green')


def failure(text):
    return _colour_text(text, 'red')


def _colour_text(text, colour):
    return click.style(text, fg=colour)


def bold(text):
    return click.style(text, bold=True)


def display_table(headers, data):
    bolded_headers = [bold(header) for header in headers]
    table_data = [bolded_headers] + data

    # Issue with less displaying SingleTable so double is needed, appears NOT to be a unicode issue
    # TODO sort this ^
    table = DoubleTable(table_data)
    table.inner_row_border = True
    click.echo_via_pager(table.table)

    # Wanted to invoke less manually so could exit if less than one screen was to be displayed
    # however there's a max length of cmd passable to Popen on the bash side of things
    # (128kbs I think) and the table often exceeds that
    #echoed_table = subprocess.Popen(("echo", table.table), stdout=subprocess.PIPE)
    #subprocess.run(["less", "-R", "-F"], stdin=echoed_table.stdout)
    #echoed_table.stdout.close()
    #echoed_table.wait()

def help_text_literal_paragraph(*parts):
    """Get text as a paragraph which will have indentation preserved in help"""
    # See http://click.pocoo.org/6/api/#click.wrap_text for explanation.
    return '\n\n\b\n' + ''.join(parts) + '\n\n'


def indented_list(*lines):
    """Get argument lines as an indented list"""
    return '\n\t' + '\n\t'.join(lines)
