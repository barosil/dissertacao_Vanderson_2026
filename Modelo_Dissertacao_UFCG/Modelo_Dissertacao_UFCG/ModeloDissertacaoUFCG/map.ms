# Medidas de um radiotelescópio de trânsito e o problema de construção de mapas

Considere um radiotelescópio de trânsito cujo diagrama de sensibilidade (ou padrão de feixe) seja conhecido e denotado por

[
B_\nu(\theta),
]

onde $\nu$ representa a frequência de observação e $\theta$ a distância angular ao centro do feixe. Assumiremos, por simplicidade, um feixe com simetria azimutal.

O céu possui uma distribuição de brilho específica

[
S_\nu(\alpha,\delta),
]

dependente da ascensão reta $\alpha$, da declinação $\delta$ e da frequência $\nu$.

Ao longo do tempo, a rotação da Terra desloca o feixe sobre o céu, permitindo que diferentes regiões sejam amostradas sucessivamente.

---

## Equação de medida

A potência observada pelo instrumento em um instante $t$ e em uma frequência $\nu$ é dada pela convolução entre o brilho do céu e o padrão de resposta da antena.

Escrevemos

[
d(t,\nu)
========

\int_{4\pi}
B_\nu\bigl(\hat{\mathbf n},t\bigr),
S_\nu(\hat{\mathbf n})
,d\Omega
+
n(t,\nu),
]

onde

* $\hat{\mathbf n}$ é um vetor unitário apontando para uma direção da esfera celeste;
* $d\Omega$ é o elemento de ângulo sólido;
* $n(t,\nu)$ representa o ruído instrumental.

De forma explícita,

[
d\Omega=\cos\delta, d\alpha, d\delta.
]

Equivalentemente,

[
d(t,\nu)
========

\int_0^{2\pi}
\int_{-\pi/2}^{\pi/2}
B_\nu(\alpha-\alpha_t,\delta)
S_\nu(\alpha,\delta)
\cos\delta,
d\delta,d\alpha
+n(t,\nu),
]

onde

[
\alpha_t=\omega_\oplus t
]

representa a ascensão reta observada devido à rotação terrestre.

---

## Medidas espectrais

Na prática, o sinal é digitalizado e dividido em $n_{\rm channels}$ canais espectrais por meio de uma FFT.

Para cada instante de tempo $t_i$ e canal espectral $\nu_j$, calcula-se a densidade espectral de potência (PSD).

Obtém-se então uma matriz observacional

[
D_{ij}=d(t_i,\nu_j),
]

com dimensão

[
N_t\times N_\nu,
]

onde

* $N_t$ é o número de amostras temporais;
* $N_\nu=n_{\rm channels}$.

Cada elemento da matriz representa a potência recebida pelo radiotelescópio em um determinado instante e frequência.

---

## Pixelização da esfera com HEALPix

O algoritmo HEALPix (*Hierarchical Equal Area isoLatitude Pixelization*) fornece uma discretização eficiente da esfera celeste.

Sua principal característica é dividir a esfera em pixels de áreas exatamente iguais.

A resolução é controlada pelo parâmetro

[
N_{\rm side},
]

e o número total de pixels é

[
N_{\rm pix}=12N_{\rm side}^2.
]

Cada pixel $p$ representa uma pequena região angular da esfera.

A distribuição contínua de brilho do céu passa então a ser representada por um vetor discreto

[
\mathbf{s}*\nu=
(s*{1,\nu},s_{2,\nu},\ldots,s_{N_{\rm pix},\nu})^T.
]

O padrão de feixe também pode ser amostrado sobre a mesma pixelização.

A integral contínua é aproximada por uma soma

[
\int_{4\pi}
f(\hat{\mathbf n}),d\Omega
\approx
\sum_{p=1}^{N_{\rm pix}}
f_p,\Delta\Omega,
]

com

[
\Delta\Omega=
\frac{4\pi}{N_{\rm pix}}.
]

---

## Formulação matricial do problema

Após a discretização, a equação de medida torna-se

[
d_{i,\nu}
=========

\sum_{p=1}^{N_{\rm pix}}
A_{ip,\nu},
s_{p,\nu}
+
n_{i,\nu},
]

onde

[
A_{ip,\nu}
==========

B_\nu(\hat{\mathbf n}_p,t_i),\Delta\Omega
]

é a matriz de apontamento (*pointing matrix*).

Em notação matricial,

[
\boxed{
\mathbf d_\nu=
\mathbf A_\nu\mathbf s_\nu+\mathbf n_\nu
}
]

com

[
\mathbf d_\nu\in\mathbb R^{N_t},
]

[
\mathbf A_\nu\in\mathbb R^{N_t\times N_{\rm pix}},
]

[
\mathbf s_\nu\in\mathbb R^{N_{\rm pix}}.
]

---

## O problema matemático da construção de mapas

O objetivo do *map-making* consiste em estimar a distribuição de brilho do céu

[
\mathbf s_\nu
]

a partir das observações

[
\mathbf d_\nu.
]

Trata-se de um problema inverso.

Como o sistema é afetado por ruído, busca-se a solução que minimize o erro quadrático ponderado

[
\chi^2=
(\mathbf d-\mathbf A\mathbf s)^T
\mathbf N^{-1}
(\mathbf d-\mathbf A\mathbf s),
]

onde

[
\mathbf N=
\langle
\mathbf n\mathbf n^T
\rangle
]

é a matriz de covariância do ruído.

A condição de mínimo conduz às equações normais

[
\boxed{
\hat{\mathbf s}
===============

(\mathbf A^T\mathbf N^{-1}\mathbf A)^{-1}
\mathbf A^T\mathbf N^{-1}\mathbf d
}
]

que constituem a solução de máxima verossimilhança para ruído gaussiano.

---

## Interpretação física

O problema da construção de mapas pode ser interpretado como a tarefa de **desfazer o efeito do feixe do instrumento e combinar milhares de observações temporais ruidosas para reconstruir a distribuição de brilho do céu em cada frequência observada**.

Cada amostra temporal não corresponde a um único ponto do céu, mas sim a uma **média ponderada** de uma região angular determinada pelo padrão de feixe do radiotelescópio.

O processo de *map-making* consiste, portanto, em inverter essa operação de convolução, levando em consideração a geometria do instrumento, a cobertura observacional e as propriedades estatísticas do ruído.

Em experimentos de mapeamento cosmológico, essa etapa constitui a ponte entre os **dados instrumentais brutos (PSD versus tempo e frequência)** e os **cubos tridimensionais de brilho do céu (ascensão reta, declinação e frequência)** que serão posteriormente utilizados para análise científica.



# Derivação da solução de máxima verossimilhança

Considere a equação de medida discretizada

[
\boxed{
\mathbf d=\mathbf A\mathbf s+\mathbf n
}
]

onde

* $\mathbf d\in\mathbb R^{N_t}$ é o vetor de observações;
* $\mathbf s\in\mathbb R^{N_{\rm pix}}$ é o mapa desconhecido que desejamos reconstruir;
* $\mathbf A\in\mathbb R^{N_t\times N_{\rm pix}}$ é a matriz de apontamento;
* $\mathbf n\in\mathbb R^{N_t}$ é o ruído instrumental.

Assumiremos que o ruído possui média nula

[
\langle \mathbf n\rangle=0,
]

e matriz de covariância

[
\boxed{
\mathbf N
=========

\langle
\mathbf n\mathbf n^T
\rangle.
}
]

Além disso, assumimos que o ruído é gaussiano.

---

## Distribuição de probabilidade do ruído

Para um vetor aleatório gaussiano multivariado, a densidade de probabilidade é

[
p(\mathbf n)
============

\frac{1}
{\sqrt{(2\pi)^{N_t}\det\mathbf N}}
\exp\left[
-\frac12
\mathbf n^T
\mathbf N^{-1}
\mathbf n
\right].
]

Como

[
\mathbf n=\mathbf d-\mathbf A\mathbf s,
]

a probabilidade de observarmos os dados $\mathbf d$, dado um mapa $\mathbf s$, é

[
\boxed{
p(\mathbf d|\mathbf s)
======================

\frac{1}
{\sqrt{(2\pi)^{N_t}\det\mathbf N}}
\exp\left[
-\frac12
(\mathbf d-\mathbf A\mathbf s)^T
\mathbf N^{-1}
(\mathbf d-\mathbf A\mathbf s)
\right].
}
]

Essa função é denominada **função de verossimilhança**.

---

## Princípio da máxima verossimilhança

O estimador de máxima verossimilhança é definido como o valor de $\mathbf s$ que maximiza

[
p(\mathbf d|\mathbf s).
]

Como a função exponencial é monotônica, é equivalente maximizar seu logaritmo.

Definimos

[
\mathcal L(\mathbf s)
=====================

\ln p(\mathbf d|\mathbf s).
]

Substituindo,

[
\mathcal L(\mathbf s)
=====================

-\frac{N_t}{2}\ln(2\pi)
-\frac12\ln\det\mathbf N
-\frac12
(\mathbf d-\mathbf A\mathbf s)^T
\mathbf N^{-1}
(\mathbf d-\mathbf A\mathbf s).
]

Os dois primeiros termos não dependem de $\mathbf s$ e podem ser ignorados.

Portanto, maximizar a verossimilhança equivale a minimizar

[
\boxed{
\chi^2
======

(\mathbf d-\mathbf A\mathbf s)^T
\mathbf N^{-1}
(\mathbf d-\mathbf A\mathbf s).
}
]

Essa é a função custo do problema.

---

## Expansão do funcional

Expandindo,

[
\chi^2=
(\mathbf d^T-\mathbf s^T\mathbf A^T)
\mathbf N^{-1}
(\mathbf d-\mathbf A\mathbf s).
]

Distribuindo os termos,

[
\chi^2=
\mathbf d^T\mathbf N^{-1}\mathbf d
-\mathbf d^T\mathbf N^{-1}\mathbf A\mathbf s
-\mathbf s^T\mathbf A^T\mathbf N^{-1}\mathbf d
+\mathbf s^T\mathbf A^T\mathbf N^{-1}\mathbf A\mathbf s.
]

Como o segundo e o terceiro termos são escalares,

[
\mathbf d^T\mathbf N^{-1}\mathbf A\mathbf s
===========================================

\mathbf s^T\mathbf A^T\mathbf N^{-1}\mathbf d,
]

obtemos

[
\boxed{
\chi^2=
\mathbf d^T\mathbf N^{-1}\mathbf d
-2\mathbf s^T\mathbf A^T\mathbf N^{-1}\mathbf d
+\mathbf s^T\mathbf A^T\mathbf N^{-1}\mathbf A\mathbf s.
}
]

---

## Condição de extremum

Calculamos o gradiente em relação a $\mathbf s$.

Utilizando a identidade matricial

[
\frac{\partial}{\partial \mathbf x}
(\mathbf x^T\mathbf M\mathbf x)
===============================

2\mathbf M\mathbf x
]

para $\mathbf M$ simétrica, temos

[
\nabla_{\mathbf s}\chi^2
========================

-2\mathbf A^T\mathbf N^{-1}\mathbf d
+
2\mathbf A^T\mathbf N^{-1}\mathbf A\mathbf s.
]

A condição de máximo da verossimilhança (ou mínimo de $\chi^2$) é

[
\nabla_{\mathbf s}\chi^2=0.
]

Portanto,

[
-2\mathbf A^T\mathbf N^{-1}\mathbf d
+
2\mathbf A^T\mathbf N^{-1}\mathbf A\mathbf s=0.
]

Dividindo por 2,

[
\boxed{
\mathbf A^T\mathbf N^{-1}\mathbf A,\mathbf s
============================================

\mathbf A^T\mathbf N^{-1}\mathbf d.
}
]

Essas são as **equações normais**.

---

## Solução de máxima verossimilhança

Se a matriz

[
\mathbf A^T\mathbf N^{-1}\mathbf A
]

for inversível, obtemos

[
\boxed{
\hat{\mathbf s}
===============

(\mathbf A^T\mathbf N^{-1}\mathbf A)^{-1}
\mathbf A^T\mathbf N^{-1}\mathbf d.
}
]

Esse é o estimador de máxima verossimilhança.

---

## Interpretação geométrica

A matriz

[
\mathbf W=\mathbf N^{-1}
]

atua como uma **matriz de pesos**.

Observações mais ruidosas recebem menor peso, enquanto observações mais precisas contribuem mais fortemente para a reconstrução.

A matriz

[
\mathbf A^T\mathbf N^{-1}\mathbf A
]

é frequentemente denominada **matriz de Fisher** ou **matriz de curvatura**, pois quantifica a quantidade de informação observacional disponível para reconstruir cada pixel do mapa.

---


Eu proporia descrever um método de **map-making por máxima verossimilhança**, pois ele estabelece uma ponte natural entre a formulação matemática anterior e a implementação computacional. Além disso, a apresentação pode ser feita de maneira gradual, do ponto de vista físico até o algoritmo.

# Método de construção de mapas (*Map-Making*)

O objetivo da construção de mapas (*map-making*) é estimar a distribuição de brilho do céu a partir de uma sequência temporal de observações realizadas por um radiotelescópio de trânsito.

As observações consistem em medidas da densidade espectral de potência (PSD) obtidas em cada instante de tempo e para cada canal espectral. Cada medida corresponde a uma média ponderada da emissão proveniente de uma região do céu determinada pelo padrão de feixe do instrumento.

Após a discretização da esfera celeste utilizando a pixelização HEALPix, o problema pode ser escrito como

[
\mathbf d=\mathbf A\mathbf s+\mathbf n,
]

onde

* $\mathbf d$ é o vetor de observações;
* $\mathbf s$ é o mapa do céu a ser reconstruído;
* $\mathbf A$ é a matriz de apontamento;
* $\mathbf n$ representa o ruído instrumental.

---

## Etapa 1: Pixelização do céu

Escolhe-se uma resolução angular através do parâmetro

[
N_{\rm side}.
]

O número total de pixels é

[
N_{\rm pix}=12N_{\rm side}^2.
]

Cada pixel representa uma pequena região da esfera celeste e armazena a intensidade média do brilho nessa direção.

O objetivo do algoritmo é estimar

[
s_p,\qquad p=1,\ldots,N_{\rm pix}.
]

---

## Etapa 2: Determinação da matriz de apontamento

Para cada instante de observação $t_i$ determina-se a orientação do feixe sobre a esfera celeste.

A contribuição de cada pixel para a observação é dada pelo valor do padrão de feixe naquela direção.

Os elementos da matriz de apontamento são

[
A_{ip}=B(\hat{\mathbf n}_p,t_i),\Delta\Omega,
]

onde

[
\Delta\Omega=\frac{4\pi}{N_{\rm pix}}
]

é a área angular de cada pixel.

Cada linha da matriz $\mathbf A$ descreve quais regiões do céu contribuíram para uma determinada observação.

---

## Etapa 3: Construção do modelo observacional

Para cada frequência $\nu$ obtemos um sistema linear

[
d_i=
\sum_{p=1}^{N_{\rm pix}}
A_{ip},s_p+n_i.
]

Escrevendo em forma matricial,

[
\mathbf d=\mathbf A\mathbf s+\mathbf n.
]

Tipicamente,

[
N_t\gg N_{\rm pix},
]

ou seja, existem muito mais observações temporais do que pixels a serem reconstruídos.

---

## Etapa 4: Definição da matriz de covariância do ruído

Assume-se que o ruído possui média nula

[
\langle \mathbf n\rangle=0
]

e covariância

[
\mathbf N=
\langle
\mathbf n\mathbf n^T
\rangle.
]

Se o ruído for branco,

[
\mathbf N=\sigma^2\mathbf I.
]

Caso existam correlações temporais, $\mathbf N$ torna-se uma matriz não diagonal.

---

## Etapa 5: Estimador de máxima verossimilhança

Define-se a função custo

[
\chi^2=
(\mathbf d-\mathbf A\mathbf s)^T
\mathbf N^{-1}
(\mathbf d-\mathbf A\mathbf s).
]

A minimização conduz ao estimador

[
\boxed{
\hat{\mathbf s}
===============

(\mathbf A^T\mathbf N^{-1}\mathbf A)^{-1}
\mathbf A^T\mathbf N^{-1}\mathbf d
}
]

que fornece o mapa reconstruído.

---

## Etapa 6: Resolução numérica

Em experimentos reais, a inversão direta é computacionalmente inviável.

Em vez disso, resolve-se o sistema linear

[
\boxed{
\mathbf H,\hat{\mathbf s}
=========================

\mathbf b
}
]

onde

[
\mathbf H=
\mathbf A^T\mathbf N^{-1}\mathbf A
]

e

[
\mathbf b=
\mathbf A^T\mathbf N^{-1}\mathbf d.
]

A solução é obtida por métodos iterativos, como o gradiente conjugado.

O processo iterativo é interrompido quando

[
\frac{|\mathbf r_k|}
{|\mathbf b|}
<\varepsilon,
]

onde

[
\mathbf r_k=\mathbf b-\mathbf H\mathbf s_k
]

é o vetor residual.

---

## Algoritmo resumido

O procedimento pode ser resumido da seguinte forma:

```text
Entrada:
    PSD(t,ν)
    Bν(θ)
    Nside
    Modelo de ruído

1. Pixelizar a esfera com HEALPix

2. Para cada instante ti:
       calcular o apontamento
       construir a linha Ai da matriz A

3. Construir o vetor de observações d

4. Estimar a matriz de ruído N

5. Construir:

       H = Aᵀ N⁻¹ A

       b = Aᵀ N⁻¹ d

6. Resolver:

       H s = b

7. Reconstruir o mapa ŝ

Saída:
    ŝ(ra,dec,ν)
```

---

## Interpretação física

Cada observação temporal não mede um único pixel do céu. Ela corresponde à média ponderada de uma região angular definida pelo padrão de feixe do instrumento.

O algoritmo de construção de mapas combina milhares de observações sobrepostas realizadas ao longo do trânsito da Terra para estimar a distribuição de brilho do céu.

Em outras palavras, o problema consiste em **desfazer a convolução introduzida pelo feixe do radiotelescópio e combinar observações ruidosas de forma estatisticamente ótima**.

O produto final é um cubo tridimensional

[
\boxed{
S(\alpha,\delta,\nu)
}
]

cujos eixos são

* ascensão reta $\alpha$;
* declinação $\delta$;
* frequência $\nu$.

Esse cubo constitui a base para análises posteriores, como remoção de foregrounds, reconstrução espectral e estudos cosmológicos.
