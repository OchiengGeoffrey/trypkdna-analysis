#!/bin/bash
echo "========================================="
echo "  Phase 1 Toolchain Verification"
echo "========================================="
echo ""

check_tool() {
    local tool_name=$1
    local version_cmd=$2
    
    if command -v "$tool_name" &> /dev/null; then
        echo "✅ $tool_name:"
        eval "$version_cmd" 2>&1 | head -n 1
    else
        echo "❌ $tool_name: NOT FOUND"
    fi
    echo ""
}

check_tool "datasets" "datasets version"
check_tool "fasterq-dump" "fasterq-dump --version"
check_tool "samtools" "samtools --version"
check_tool "bcftools" "bcftools --version"
check_tool "bwa" "bwa"
check_tool "seqtk" "seqtk"
check_tool "transeq" "transeq -help"
check_tool "python3" "python3 --version"
check_tool "mafft" "mafft --version"

echo "========================================="
echo "  Verification Complete"
echo "========================================="
