# Scripts para cortarle los silencios a un video.

Depende principalmente de blind, ffmpeg, sox, make

Usa perl y zsh para dos líneas que podrían reemplazarse por algo mas estándar, aunque perl suele estar instalado.

## Como usar:

### Preparación

Primero debemos clonar el repositorio y copiar el video crudo adentro.

```bash
git clone https://github.com/jjclavijo/blind-drop-silence.git workdir
cd workdir
cp /path/to/video .
```

### Creación de las secciones:

Se pueden tocar los parámetros que están hardcodeados en `getSilencios.sh`
y `joinsilencios.py` para variar qué se considera "silencio".

```bash
make INPUT_VIDEO=video_file.mp4 all
```

### Pegado:

Se pueden eliminar de la carpeta videos todos los clips que estén demás.
Luego se crea una lista de archivos a unir y se los une.

```bash
make Definitivo.mp4
```

