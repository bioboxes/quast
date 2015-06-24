__author__ = 'pbelmann'

from bs4 import BeautifulSoup
import argparse
import codecs

toAppend = """   $(function() {
buildReport(); $('#contigs_are_ordered').show();
$("[rel=tooltip]").tooltip({ animation: false, });
});
"""

parser = argparse.ArgumentParser(description='Parses HTML')
parser.add_argument('--input', dest="input", required=True,
                    help='input html path')
parser.add_argument('--output', dest='output', required=True,
                    help='output html path')
parser.add_argument('--prefix', dest='prefix', required=True,
                    help='prefix for paths in src and href attributes ')
args = parser.parse_args()

prefix = args.prefix
input = args.input
output = args.output

with codecs.open(input, "r", encoding='utf-8') as htmlFile:
    html=htmlFile.read()

soup = BeautifulSoup(html, from_encoding="UTF-8")
inline_scripts = soup.findAll('script',{"src":False})
for script in inline_scripts:
    contains = False
    script.extract()

for script in soup.findAll('script',{"src":True}):
    src = script['src']
    del(script['src'])
    path = prefix + src
    with codecs.open(path, "r", encoding="utf-8") as sourceFile:
        source = sourceFile.read()
        source = source.replace("</script>",'')
        script.append(source)

for link in soup.findAll('link'):
    href = link['href']
    path = prefix + href
    tag = soup.new_tag("style", type=["text/css"])
    with codecs.open(path, "r", encoding="utf-8") as linkFile:
        style = linkFile.read()
    tag.insert(0,style)
    link.replaceWith(tag)

new_tag = soup.new_tag("script", type=["text/javascript"])
new_tag.insert(0,toAppend)
soup.html.head.append(new_tag)
output_html = str(soup)
with codecs.open(output, "w", encoding="utf-8") as file:
    file.write(output_html)


