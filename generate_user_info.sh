#!/usr/bin/env bash


HOSTS=($(tail -24 hosts | awk -F'.' '{ print $1 }'))
SECRETS_FILE=secrets.yml

LATEX_BEGIN=$(echo -ne '\\documentclass[20pt,a4paper]{article}\n\\begin{document}\n\\begin{table}\n\\centering \\Large \\begin{tabular}{ |c|c| }\n\\hline')
LATEX_END=$(echo -e '\n\\end{tabular}\n\\end{table}\n\\end{document}')
LATEX=$(echo -n "${LATEX_BEGIN}")
echo "Getting user info"
for host in ${HOSTS[@]}
do
  echo -n "."
  PASS=$(sops -d --extract '["users"]["'$host'"]["pass"]' $SECRETS_FILE)
  LATEX+=$(echo -ne "\n\t${host}.jupyter.ber.lab.alpaka.space & ${PASS}"'\\\\\n\t\\hline')
done
LATEX+=$(echo "${LATEX_END}")
echo ""
echo "Generating pdf..."
JOB_NAME=user_info
echo "${LATEX}" | pdflatex -jobname=$JOB_NAME
rm $JOB_NAME.{aux,log} #cleanup

