### <Teste técnico>
# Barcode scanner - boleto edition 🇧🇷 💸

Aplicativo desenvolvido como método avaliativo de habilidades em Flutter. A aplicação permite que o usuário utilize um dispositivo Android para escanear ó código de barras de um boleto, retornando uma visualização simples e intuitiva com as principais informações desse documento. 

# Requisitos
- <a href="https://docs.flutter.dev/get-started/install"> Flutter SDK Instalado </a>
- Dispositivo ou <a href="https://developer.android.com/studio?hl=pt-br"> emulador Android/iOS </a> 

# Instalação
1- Clone este repositório em sua máquina:

``` bash
git clone https://github.com/carolineregis/barcode_reader_v1.git

```
2- Navegue até o diretório onde o projeto foi clonado:
``` bash
cd barcode_reader_v1
```
3- Instale as dependências:
``` bash
flutter pub get
```
4- Rode o projeto:
``` bash
flutter run
```

#Testes
1. Escaneie o código de barras de um boleto, usando o dispositivo físico ou emulador. Pode-se usar o <a href="https://devtools.com.br/gerador-boleto"> gerador de boletos da devtools </a> para gerar um boleto temporário.

2. Caso o código seja lido corretamente (na sua íntegra), confira se as informações estão condizentes com o documento na página seguinte.

3. Leituras incorretas ou sem retorno geralmente são causadas por problema na captação do código pela própria câmera do dispositivo. Resolver tal problema demanda a configuração e adaptação das bibliotecas que estão sendo utilizadas (barcode_scan2 e boleto_utils). Abaixo disponibilizo um código de barras válido, que pode ser inserido manualmente no código.

 ``` bash
 if (barcode.rawContent != null) {
          // Código de barras mocado para testes. Basta descomentar a linha abaixo para utilizar o código mocado
          // boletoValidado = boletoUtils.validarBoleto(
          //     '34191.75124 34567.871230 41234.560005 1 96050000026035');
          boletoValidado = boletoUtils.validarBoleto(barcode.rawContent);
 ``` 
