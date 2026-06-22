
---

## 1. Ganho Total (Cascata)

Para **N** estágios em cascata, o ganho total em **fator linear** (não em dB) é o produto dos ganhos individuais:

\[
G_{total} = G_1 \cdot G_2 \cdot G_3 \cdots G_N = \prod_{i=1}^{N} G_i
\]

Em **dB**:

\[
G_{total,dB} = 10 \log_{10}(G_{total}) = \sum_{i=1}^{N} G_{i,dB}
\]

---

## 2. Temperatura de Ruído Equivalente (Fórmula de Friis para Temperatura)

A temperatura de ruído equivalente de toda a cadeia, referida à entrada, é dada por:

\[
T_{e,total} = T_{e,1} + \frac{T_{e,2}}{G_1} + \frac{T_{e,3}}{G_1 G_2} + \cdots + \frac{T_{e,N}}{G_1 G_2 \cdots G_{N-1}}
\]

Ou de forma compacta:

\[
\boxed{T_{e,total} = T_{e,1} + \sum_{k=2}^{N} \frac{T_{e,k}}{\prod_{j=1}^{k-1} G_j}}
\]

Onde:
- \( T_{e,i} \) = temperatura de ruído equivalente do i-ésimo estágio (em Kelvin)
- \( G_i \) = ganho linear (fator, não dB) do i-ésimo estágio

**Observação importante:** O primeiro estágio domina \( T_{e,total} \), pois os termos seguintes são divididos pelos ganhos anteriores.

---

## 3. Noise Figure Total (Fórmula de Friis para Noise Figure)

O noise figure total em **fator linear** (F) é:

\[
F_{total} = F_1 + \frac{F_2 - 1}{G_1} + \frac{F_3 - 1}{G_1 G_2} + \cdots + \frac{F_N - 1}{G_1 G_2 \cdots G_{N-1}}
\]

\[
\boxed{F_{total} = F_1 + \sum_{k=2}^{N} \frac{F_k - 1}{\prod_{j=1}^{k-1} G_j}}
\]

Em **dB**:

\[
NF_{total,dB} = 10 \log_{10}(F_{total})
\]

Onde \( F_i \) (fator linear) e \( NF_i \) (dB) se relacionam por:

\[
F_i = 10^{NF_i / 10}
\]

---

## 4. Relação entre Temperatura de Ruído e Noise Figure

Para um sistema com temperatura de referência \( T_0 = 290 \, K \) (padrão IEEE):

\[
\boxed{F = 1 + \frac{T_e}{T_0}}
\]

Ou, isolando \( T_e \):

\[
\boxed{T_e = T_0 \cdot (F - 1)}
\]

E em termos de NF (dB):

\[
T_e = T_0 \cdot \left(10^{NF/10} - 1\right)
\]

---

## 5. Equação Combinada (para 2 estágios – caso mais comum)

Para **2 LNAs** em cascata:

\[
G_{total} = G_1 \cdot G_2
\]

\[
T_{e,total} = T_{e,1} + \frac{T_{e,2}}{G_1}
\]

\[
F_{total} = F_1 + \frac{F_2 - 1}{G_1}
\]

E em dB:

\[
NF_{total} = 10 \log_{10}\left( F_1 + \frac{F_2 - 1}{G_1} \right)
\]

---

## 6. SNR na Saída (em função do NF total)

A relação sinal-ruído na saída da cadeia é dada por:

\[
SNR_{out} = SNR_{in} - NF_{total,dB}
\]

Ou em fatores lineares:

\[
\frac{SNR_{in}}{SNR_{out}} = F_{total}
\]

---

## 7. Potência de Ruído Disponível na Saída

A potência de ruído total na saída (em uma largura de banda B) é:

\[
P_{noise,out} = k \cdot B \cdot T_{e,total} \cdot G_{total} + k \cdot B \cdot T_0 \cdot G_{total}
\]

Ou simplesmente:

\[
P_{noise,out} = k \cdot B \cdot T_0 \cdot F_{total} \cdot G_{total}
\]

Onde \( k = 1,38 \times 10^{-23} \, J/K \) (constante de Boltzmann).

---

## 8. Resumo das Equações em um Quadro

| Grandeza | Equação (N estágios) | Equação (2 estágios) |
|----------|------------------------|------------------------|
| **Ganho total** | \( G_{tot} = \prod_{i=1}^{N} G_i \) | \( G_1 \cdot G_2 \) |
| **Temperatura de ruído** | \( T_{e,tot} = T_{e,1} + \sum_{k=2}^{N} \frac{T_{e,k}}{\prod_{j=1}^{k-1} G_j} \) | \( T_{e,1} + \frac{T_{e,2}}{G_1} \) |
| **Noise Figure (linear)** | \( F_{tot} = F_1 + \sum_{k=2}^{N} \frac{F_k - 1}{\prod_{j=1}^{k-1} G_j} \) | \( F_1 + \frac{F_2 - 1}{G_1} \) |
| **NF (dB)** | \( NF_{tot} = 10\log_{10}(F_{tot}) \) | \( 10\log_{10}\left(F_1 + \frac{F_2 - 1}{G_1}\right) \) |
| **Relação F ↔ Tₑ** | \( F = 1 + \frac{T_e}{T_0} \) | \( F = 1 + \frac{T_e}{T_0} \) |
| **SNR na saída** | \( SNR_{out} = SNR_{in} - NF_{tot,dB} \) | \( SNR_{in} - NF_{tot,dB} \) |

---

## 9. Exemplo Numérico com as Equações (2 LNAs)

Retomando o exemplo anterior:

- LNA1: \( G_1 = 20 \, dB = 100 \) (linear), \( NF_1 = 1,0 \, dB \Rightarrow F_1 = 10^{0,1} = 1,259 \)
- LNA2: \( G_2 = 15 \, dB = 31,62 \), \( NF_2 = 4,0 \, dB \Rightarrow F_2 = 10^{0,4} = 2,512 \)

**Cálculo do NF total:**

\[
F_{total} = 1,259 + \frac{2,512 - 1}{100} = 1,259 + 0,01512 = 1,27412
\]

\[
NF_{total,dB} = 10 \log_{10}(1,27412) \approx 1,05 \, dB
\]

**Temperatura de ruído total:**

\[
T_{e1} = 290 \cdot (1,259 - 1) = 75,1 \, K
\]
\[
T_{e2} = 290 \cdot (2,512 - 1) = 438,5 \, K
\]
\[
T_{e,total} = 75,1 + \frac{438,5}{100} = 75,1 + 4,385 = 79,485 \, K
\]

**Conferindo a relação:** \( F_{total} = 1 + \frac{79,485}{290} = 1 + 0,274 = 1,274 \) ✔

---

Essas equações mostram claramente que, para minimizar o ruído total, o **primeiro LNA deve ter baixo NF e alto ganho**, pois isso reduz o peso dos estágios seguintes na soma.