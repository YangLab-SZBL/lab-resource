# Protein Modifications in Mass Spectrometry
# 蛋白质质谱分析中的修饰设置（中英文大白话版）

## 1. Overall Principle｜核心原理

**中文：**

蛋白质由氨基酸组成。实验中，我们通常会先提取蛋白质，再通过酶切（例如 Trypsin，胰蛋白酶）把蛋白质切成很多小片段，这些小片段叫做肽段（Peptides）。

随后，质谱仪（Mass Spectrometer, MS）会测量这些肽段的质量，并根据质量信息识别肽段和蛋白质。

但是，真实样本中的蛋白质不一定是原始状态。有些氨基酸可能会发生化学修饰（Chemical Modifications），导致肽段的质量发生变化。

因此，在进行质谱数据库搜索（Database Search）时，需要提前告诉软件：

- 哪些氨基酸可能发生修饰？
- 修饰会让质量增加或减少多少？
- 哪些修饰是固定发生的？
- 哪些修饰只是可能发生的？

**English:**

Proteins are made up of amino acids. In proteomics experiments, proteins are usually extracted and digested into smaller fragments called peptides using enzymes such as trypsin.

A mass spectrometer (MS) measures the mass of these peptides, allowing researchers to identify peptides and proteins.

However, proteins in biological samples may undergo chemical modifications. These modifications change the mass of peptides.

Therefore, during database searching, we need to tell the software:

- Which amino acids can be modified?
- How much mass does each modification add or remove?
- Which modifications are fixed?
- Which modifications are variable?

---

## 2. Why Do We Use IAA for Cysteine Alkylation?｜为什么实验中要使用 IAA 对半胱氨酸进行烷基化？

### 2.1 Cysteine Has a Special Chemical Group｜半胱氨酸有什么特殊？

**中文：**

半胱氨酸（Cysteine，C）比较特殊，因为它的侧链上有一个巯基（Thiol group，-SH）。

这个巯基比较活泼，两个半胱氨酸之间可以发生氧化反应，形成二硫键（Disulfide Bond）。

简单来说，两个 C 可以通过二硫键连接在一起：

```text
Cys-SH + HS-Cys
       ↓ Oxidation（氧化）
Cys-S-S-Cys
```

二硫键可以帮助维持蛋白质的三维结构，但在质谱实验中，它可能影响蛋白质的充分展开和酶切。

**English:**

Cysteine is special because its side chain contains a thiol group (-SH).

Two cysteine residues can undergo oxidation and form a disulfide bond.

```text
Cys-SH + HS-Cys
       ↓ Oxidation
Cys-S-S-Cys
```

Disulfide bonds help stabilize protein structures. However, they can interfere with protein unfolding and digestion during proteomics experiments.

### 2.2 Reduction｜还原：打开二硫键

**中文：**

实验人员通常使用 DTT 或 TCEP 等还原剂（Reducing Agents），把二硫键打开。

```text
Cys-S-S-Cys
       ↓ Reduction（还原）
Cys-SH     HS-Cys
```

这样两个半胱氨酸就分开了。

但是，打开之后的巯基比较活泼，可能再次发生氧化，重新形成二硫键。

**English:**

Reducing agents such as DTT or TCEP are used to break disulfide bonds.

```text
Cys-S-S-Cys
       ↓ Reduction
Cys-SH     HS-Cys
```

The two cysteine residues become separated.

However, the newly exposed thiol groups are reactive and may oxidize again, reforming disulfide bonds.

### 2.3 Alkylation｜烷基化：给 C 加上保护帽

**中文：**

为了防止二硫键重新形成，实验人员通常使用 IAA（Iodoacetamide，碘乙酰胺）进行烷基化（Alkylation）。

IAA 会与半胱氨酸的巯基发生反应，给 C 加上一个化学基团。

```text
Cys-SH + IAA
       ↓ Alkylation
Cys-S-CH2-CONH2
```

这个修饰叫做：

**Carbamidomethylation（氨甲酰甲基化）**

它会让半胱氨酸的质量增加：

**+57.021464 Da**

可以把这个过程理解为：还原是把打结的绳子解开，烷基化就是给解开的线头套上保护帽，防止它们重新打结。

**English:**

To prevent disulfide bonds from reforming, researchers usually use IAA (Iodoacetamide) for alkylation.

IAA reacts with the thiol group of cysteine and adds a chemical group to it.

```text
Cys-SH + IAA
       ↓ Alkylation
Cys-S-CH2-CONH2
```

This modification is called **Carbamidomethylation**.

It increases the mass of cysteine by:

**+57.021464 Da**

In simple terms, reduction opens the disulfide bonds, while alkylation acts like a protective cap to prevent them from forming again.

---

## 3. Explanation of Each Parameter｜代码逐行解释

### Original Code｜原始代码

```bash
# Modifications
--met-excision
--unimod4
--var-mods 1
--var-mod UniMod:35,15.994915,M
--var-mod UniMod:1,42.010565,*n
```

!!! note "DIA-NN 2.x 提示"
    在新版 DIA-NN 中，半胱氨酸 Carbamidomethyl（+57.021）已是内置默认固定修饰，
    `--unimod4` 属遗留写法；实际命令模板见 [DIA-NN](../software/dia-nn.md)。
    下文仍逐行解释它的含义，便于理解旧命令。

### 3.1 `--met-excision`

**N-terminal Methionine Excision｜N端甲硫氨酸切除**

**中文：**

蛋白质合成时，通常第一个氨基酸是甲硫氨酸（Methionine，M）。

但是，在蛋白质成熟过程中，第一个 M 有时会被酶切除。

例如：

```text
Original protein:
M-A-K-L-V-G-T

After Met excision:
A-K-L-V-G-T
```

这个参数告诉软件：允许蛋白质最前面的 M 被切除。

这样软件就可以同时考虑切除前和切除后的情况。

**English:**

The first amino acid of a newly synthesized protein is often methionine (M).

During protein maturation, the initial methionine may be removed by cellular enzymes.

This parameter tells the software to consider the possibility of N-terminal methionine removal.

### 3.2 `--unimod4`

**Carbamidomethylation｜半胱氨酸烷基化**

**中文：**

实验中使用 IAA 对半胱氨酸（C）进行烷基化，形成 Carbamidomethylation 修饰。

质量增加：

**+57.021464 Da**

因为实验中通常假设所有符合条件的 C 都已经发生了这个修饰，所以它属于固定修饰（Fixed Modification）。

例如：

```text
Original peptide:
PEPTCIDEK

After alkylation:
PEPTC(+57.021464)IDEK
```

软件看到 C，就自动给它增加 57.021464 Da。

**English:**

Cysteine residues are usually alkylated with IAA during sample preparation.

This produces Carbamidomethylation, which increases the mass by +57.021464 Da.

It is defined as a fixed modification because we generally assume that all cysteine residues have been alkylated.

### 3.3 `--var-mods 1`

**Maximum Number of Variable Modifications｜可变修饰数量限制**

**中文：**

这个参数表示每条肽段最多允许出现 1 个可变修饰。

为什么要限制？

因为如果允许很多修饰同时发生，软件需要搜索更多修饰组合，计算量会增加，也可能增加错误匹配的机会。

注意：

- 固定修饰不计入这个数量。
- 可变修饰最多允许 1 个。
- 这是每条肽段的限制，不是整个蛋白质的限制。

**English:**

This parameter limits each peptide to a maximum of one variable modification.

Without this restriction, the software would need to search through many possible modification combinations, increasing computational complexity.

Fixed modifications are not counted toward this limit.

### 3.4 `--var-mod UniMod:35,15.994915,M`

**Methionine Oxidation｜甲硫氨酸氧化**

**中文：**

甲硫氨酸（M）容易发生氧化。

氧化后，质量增加：

**+15.994915 Da**

例如：

```text
Unmodified:
PEPTMIDEK

Oxidized:
PEPTM(ox)IDEK
```

为什么是可变修饰（Variable Modification）？

因为并不是所有 M 都一定发生氧化。

软件需要考虑两种可能：

1. M 没有氧化，质量不变。
2. M 发生氧化，质量增加 15.994915 Da。

**English:**

Methionine (M) can undergo oxidation.

Oxidation increases its mass by +15.994915 Da.

It is considered a variable modification because not every methionine residue is necessarily oxidized.

The software considers both modified and unmodified possibilities.

### 3.5 `--var-mod UniMod:1,42.010565,*n`

**Protein N-terminal Acetylation｜蛋白质N端乙酰化**

**中文：**

乙酰化（Acetylation）是一种常见的蛋白质翻译后修饰（Post-translational Modification, PTM）。

它通常发生在蛋白质的 N 端。

质量增加：

**+42.010565 Da**

例如：

```text
Original:
M-A-K-L-V-G-T

After N-terminal acetylation:
Ac-M-A-K-L-V-G-T
```

这里的 `*n` 表示 Protein N-terminus，也就是蛋白质的 N 端，而不是任意肽段的 N 端。

它是可变修饰，因为并不是所有蛋白质都一定发生 N 端乙酰化。

**English:**

Acetylation is a common post-translational modification (PTM).

It can occur at the protein N-terminus, increasing the mass by +42.010565 Da.

The notation `*n` represents the protein N-terminus, rather than the N-terminus of any internal peptide.

It is a variable modification because not all proteins are necessarily acetylated.

---

## 4. Summary Table｜参数总结

| Parameter | Modification | Mass Change | Type |
|---|---|---:|---|
| `--met-excision` | N-terminal Met removal | -131.0405 Da* | Special processing |
| `--unimod4` | Cysteine carbamidomethylation | +57.021464 Da | Fixed |
| `--var-mods 1` | Maximum variable modifications | — | Search setting |
| `UniMod:35` | Methionine oxidation | +15.994915 Da | Variable |
| `UniMod:1` | Protein N-terminal acetylation | +42.010565 Da | Variable |

\*注：Met 切除的质量变化是按甲硫氨酸残基质量计算的，实际肽段质量变化还需要结合具体序列和末端情况理解。

---

## 5. How Does the Software Use These Parameters?｜软件到底是怎么利用这些参数的？

**中文：**

可以假设有一条肽段：

```text
MACK
```

软件会按照以下逻辑进行搜索：

**Step 1：考虑 N 端 M 是否被切除**

```text
MACK → ACK
```

**Step 2：考虑固定修饰**

C 一定增加 +57.021464 Da。

```text
MACK → MA(C+57)K
```

**Step 3：考虑可变修饰**

软件最多考虑一个可变修饰：

- M 没有氧化。
- M 发生氧化（+15.994915 Da）。
- 符合条件的蛋白质 N 端发生乙酰化（+42.010565 Da）。

注意：只有真正位于蛋白质 N 端的肽段才能使用这里定义的 Protein N-terminal Acetylation。

**Step 4：与质谱数据进行匹配**

软件计算各种可能情况下的理论肽段质量，再与质谱仪实际测量的质量进行比较。

如果理论质量与实验测量质量足够接近，并且碎片离子等证据也支持，就可以认为这个肽段匹配成功。

**English:**

Suppose we have a peptide:

```text
MACK
```

The software follows these steps:

**Step 1: Consider N-terminal methionine excision**

```text
MACK → ACK
```

**Step 2: Apply fixed modifications**

Cysteine automatically receives +57.021464 Da.

**Step 3: Consider variable modifications**

The software considers at most one variable modification per peptide:

- Methionine remains unoxidized.
- Methionine is oxidized (+15.994915 Da).
- Protein N-terminal acetylation occurs (+42.010565 Da), if the peptide is at the protein N-terminus.

**Step 4: Match theoretical and experimental masses**

The software calculates theoretical peptide masses under the allowed modification combinations and compares them with the masses measured by the mass spectrometer.

Additional evidence, such as fragment ion matching, helps determine the correct peptide identification.

---

## 6. The Most Important Logic｜最重要的核心逻辑

整个代码背后的逻辑可以总结为：

**中文：**

1. 蛋白质实验阶段：通过还原和烷基化处理半胱氨酸，防止二硫键重新形成。
2. 固定修饰：告诉软件 C 已经被烷基化，质量增加 57.021464 Da。
3. 可变修饰：告诉软件 M 可能氧化，蛋白质 N 端可能乙酰化。
4. 搜索限制：每条肽段最多允许一个可变修饰，控制搜索复杂度。
5. 最终目的：让软件计算出更准确的理论肽段质量，与实验质谱数据进行匹配，从而提高蛋白质鉴定的准确性。

**English:**

1. Sample preparation: Reduction and alkylation are performed to break disulfide bonds and prevent their reformation.
2. Fixed modification: The software is instructed to add +57.021464 Da to cysteine residues.
3. Variable modifications: Methionine oxidation and protein N-terminal acetylation are considered possible modifications.
4. Search restriction: A maximum of one variable modification per peptide is allowed to control search complexity.
5. Final goal: To calculate accurate theoretical peptide masses and match them with experimental MS data for reliable protein identification.

### One-Sentence Take-Home Message｜一句话记住

**中文：**

这些参数本质上是在告诉质谱搜索软件：蛋白质可能发生了哪些化学变化、这些变化会让质量改变多少，以及软件应该按照什么规则搜索，最终才能更准确地识别蛋白质。

**English:**

These parameters tell the mass spectrometry search software which chemical modifications may occur, how they change peptide masses, and what rules should be used to identify proteins accurately.
