Salesforce DX Project - Curso Developer
Repositorio oficial con código, recursos y ejercicios del curso de desarrollo en la plataforma de Salesforce.

🚀 Guía de Conexión y Sincronización para Estudiantes
Sigue estas instrucciones para conectar tu proyecto local de VS Code con este repositorio y mantener tu código actualizado durante el curso.

📌 Paso 1: Configuración Inicial (Solo la primera vez)
Abre la terminal integrada en VS Code dentro de la raíz de tu proyecto local y ejecuta los siguientes comandos en orden:

Inicializar el repositorio Git localmente:

Bash
git init
Añadir el repositorio del profesor como remoto:

Bash
git remote add Josue https://github.com/josueblandon123/Curso-Developer.git
Descargar e integrar los archivos por primera vez:

Bash
git pull Josue main --allow-unrelated-histories
💡 Nota: La opción --allow-unrelated-histories es necesaria únicamente en este paso para permitir unir tu proyecto local con el historial de GitHub.

🔄 Paso 2: Flujo de Trabajo Diario (Descargar actualizaciones)
Cada vez que se publique nuevo material, ejercicios o clases Apex en el repositorio:

Asegúrate de estar ubicado en la rama main:

Bash
git switch main
Descargar los últimos cambios:

Bash
git pull Josue main
Desplegar el nuevo código a tu Org de Salesforce:

En VS Code, haz clic derecho sobre la carpeta force-app o sobre el archivo manifest/package.xml.

Selecciona la opción SFDX: Deploy Source to Org (o Deploy Source in Manifest to Org).

⚠️ Solución de Problemas (Reset Local)
Si modificaste archivos localmente y Git no te deja hacer el pull por conflictos, puedes sincronizar tu proyecto local para que quede exactamente igual al del repositorio ejecutando:

Bash
git fetch Josue
git reset --hard Josue/main
(Advertencia: Este comando descarte cualquier cambio local no guardado).

📋 Requisitos Previos
Asegúrate de tener instalado y configurado lo siguiente en tu equipo:

Salesforce CLI - Descargar desde developer.salesforce.com/tools/salesforcecli.

VS Code con el Salesforce Extension Pack.

Org de Desarrollo (Developer Edition) - Puedes registrar una gratis aquí.

📂 Estructura del Proyecto
force-app/main/default/ - Contiene todo el código fuente del proyecto (clases Apex, componentes LWC, triggers, objetos personalizados, etc.).

manifest/package.xml - Archivo manifiesto utilizado para desplegar y recuperar componentes específicos de la Org.

config/ - Archivos de configuración y definiciones para Scratch Orgs.

🛠️ Comandos Frecuentes de Salesforce CLI
sf org login web: Autorizar una Org de desarrollo en el navegador.

sf org open: Abrir la Org autorizada directamente en el navegador.

sf project deploy start: Desplegar metadatos desde tu equipo local hacia la Org.

sf project retrieve start: Descargar metadatos desde la Org hacia tu equipo local.

sf apex run --file <filepath>: Ejecutar código Apex anónimo desde un archivo local.