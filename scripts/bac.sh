#!/bin/bash
set -e

# Parameters
env_name="bac_env"
python_version="3.12"

# 修正环境根目录为实际位置
export MAMBA_EXE="$HOME/.local/bin/micromamba"
export MAMBA_ROOT_PREFIX="$HOME/.local/share/mamba"

# Create environment if not exists (使用绝对路径，防止找不到)
ENV_PATH="$MAMBA_ROOT_PREFIX/envs/$env_name"
if [ -d "$ENV_PATH" ]; then
    echo "Environment $env_name already exists"
else
    echo "Creating micromamba environment: $env_name"
    micromamba create -y -p "$ENV_PATH" python="$python_version"
fi

# Activate environment shell support
eval "$($MAMBA_EXE shell hook --shell bash)"

# ✅ Install parquet-tools (using conda-forge channel)
echo "Installing parquet-tools..."
micromamba install -y -p "$ENV_PATH" -c conda-forge parquet-tools

# Install scientific packages 
micromamba run -p "$ENV_PATH" pip install \
  numpy pandas matplotlib seaborn tqdm scikit-learn statsmodels \
  h5py networkx pyro-ppl pysam snakemake \
  pyteomics lxml biopython joblib pyarrow xlsxwriter openpyxl

# ✅ Install ipykernel & jupyter (for kernel registration)
echo "Installing ipykernel..."
micromamba run -p "$ENV_PATH" pip install -U pip ipykernel jupyter

# ✅ Register Jupyter kernel
echo "Registering Jupyter kernel..."
micromamba run -p "$ENV_PATH" python -m ipykernel install --user --name "$env_name" --display-name "Python ($env_name)"

# Verify key imports (已移除 torch)
modules=(numpy pandas snakemake pyteomics lxml biopython)
all_ok=true
for mod in "${modules[@]}"; do
    echo -n "Importing $mod... "
    micromamba run -p "$ENV_PATH" python -c "import $mod" &>/dev/null && echo "OK" || { echo "FAILED"; all_ok=false; }
done

# ✅ Verify parquet-tools installation
echo -n "Checking parquet-tools... "
if micromamba run -p "$ENV_PATH" parquet-tools --version &>/dev/null; then
    echo "OK"
else
    echo "FAILED"
    all_ok=false
fi

# ✅ Verify Jupyter kernel registration
echo -n "Checking Jupyter kernel... "
if micromamba run -p "$ENV_PATH" jupyter kernelspec list | grep -q "$env_name"; then
    echo "OK"
else
    echo "FAILED"
    all_ok=false
fi

# Summary
if [ "$all_ok" = true ]; then
    echo "🎉 Environment $env_name is ready and Jupyter kernel installed!"
else
    echo "⚠️ Some packages failed to import or verify"
fi
