# 🏛️ Documentación de Arquitectura y Flujo de Trabajo

Este documento detalla los principios de diseño, la justificación de las herramientas y el desglose fase por fase de la implementación de Infraestructura como Código (IaC) en este repositorio.

---

## 1. Diferencia Clave: Terraform vs. Terragrunt

### ❌ El problema con Terraform "Puro" (Vanilla)
En una implementación tradicional de Terraform, para tener 3 entornos (Dev, QA, Prod), tendrías que:
1.  Copiar el bloque `provider "aws" {...}` en 3 archivos distintos.
2.  Copiar la configuración del `backend "s3" {...}` en 3 archivos distintos.
3.  Si quieres actualizar la versión de Terraform, debes editar 3 archivos.

**Resultado:** Código duplicado (WET - Write Everything Twice), difícil de mantener y propenso a errores humanos.

### ✅ La solución con Terragrunt (DRY)
Terragrunt actúa como un "wrapper" (envoltorio) u orquestador que se ejecuta *antes* de Terraform.
1.  **Herencia de Backend:** Definimos el S3 bucket **una sola vez** en la raíz (`live/terragrunt.hcl`). Los entornos "hijos" heredan esta configuración automáticamente.
2.  **Inyección de Variables:** El código de la infraestructura (EC2, SG) vive aislado en `modules/`. Terragrunt simplemente "inyecta" valores (inputs) a ese módulo dependiendo de si estamos en Dev o Prod.
3.  **Código Inmutable:** El módulo lógico nunca se toca. Solo cambiamos los archivos de configuración `.hcl`.

---

## 2. Estructura de Directorios: ¿Por qué así?

La estructura se divide en dos mundos separados para garantizar seguridad y escalabilidad:

### 📂 `modules/` (La Lógica / La Receta)
* Aquí reside el código Terraform puro (`main.tf`, `variables.tf`).
* **No sabe nada del entorno:** No sabe si es Dev o Prod. Solo sabe "cómo crear un servidor".
* **Ventaja:** Si cometemos un error aquí, lo arreglamos una vez y se propaga a todos los entornos controladamente.

### 📂 `live/` (La Implementación / El Menú)
* Aquí reside la configuración de Terragrunt (`terragrunt.hcl`).
* **Aislamiento:** Cada entorno (`dev/`, `qa/`, `prod/`) es una carpeta separada.
* **Ventaja:** Si rompes la configuración en `dev`, **NO** afectas a `prod`. Tienen archivos de estado (`tfstate`) totalmente independientes en S3.

---

## 3. Reutilización de Variables

El flujo de datos funciona así:

1.  **Módulo (`modules/compute-instance/variables.tf`):**
    * Declara: "Necesito una variable llamada `instance_type` y otra `env`".
    * No tiene valores, solo requisitos.

2.  **Terragrunt (`live/dev/terragrunt.hcl`):**
    * Bloque `inputs = { ... }`: Aquí es donde definimos los valores reales.
    * Dev dice: `instance_type = "t3.micro"`
    * Prod dice: `instance_type = "t3.large"` (o micro para este lab).

**Resultado:** Usamos el mismo código de creación de servidores para todos, pero cada uno se comporta diferente según sus inputs.

---

## 4. Prerrequisitos Críticos

Para que esta orquestación funcione, se requieren herramientas externas que hemos automatizado en los scripts:

* **Terragrunt:** El binario que lee los archivos `.hcl` y ejecuta terraform por nosotros. Sin él, la estructura `live/` no sirve.
* **JQ:** Una herramienta de línea de comandos para procesar JSON.
    * *¿Por qué la necesitamos?* El script `99_nuke_backend.sh` necesita leer la lista de versiones de objetos en S3 (que AWS devuelve en formato JSON) para poder borrarlas una por una. Sin `jq`, no podríamos automatizar la limpieza profunda del bucket.

---

## 5. Desglose de Fases (Paso a Paso)

### 🟢 Fase 1: Bootstrapping (Cimientos)
**Acción:** Ejecución de `./scripts/00_init_backend.sh` y `./scripts/install_terragrunt.sh`.
* **Qué hace:** Instala el binario necesario y crea el Bucket S3 con cifrado y bloqueo.
* **Por qué:** Terraform necesita un lugar remoto y seguro para guardar su "memoria" (state). No podemos empezar sin esto.

### 🔵 Fase 2: Inicialización (Init)
**Acción:** `terragrunt init` en cada carpeta de entorno.
* **Qué hace:**
    1.  Terragrunt lee el archivo padre (`root`).
    2.  Genera un archivo `backend.tf` temporal con la config del S3.
    3.  Descarga el código del módulo desde `../../modules`.
    4.  Descarga los plugins de AWS (Provider).

### 🟡 Fase 3: Planificación (Plan)
**Acción:** `terragrunt plan`.
* **Qué hace:** Compara lo que hay en AWS (nada o estado actual) con lo que dice tu código.
* **Resultado:** Te muestra una "promesa" de lo que va a crear. Es tu última oportunidad de abortar si ves algo mal.

### 🟠 Fase 4: Aplicación (Apply)
**Acción:** `terragrunt apply`.
* **Qué hace:**
    1.  Llama a la API de AWS para crear los recursos.
    2.  Escribe en el archivo `terraform.tfstate` en el S3: "He creado la instancia X con ID Y".
    3.  Aplica los Tags definidos en los inputs.

### 🟣 Fase 5: Auditoría (FinOps)
**Acción:** `./scripts/audit_finops.sh`.
* **Qué hace:** Usa AWS CLI para filtrar recursos por el Tag `Repo`.
* **Objetivo:** Verificar que lo que creemos que está desplegado coincide con la realidad y evitar costos ocultos.

### 🔴 Fase 6: Destrucción (Destroy & Nuke)
**Acción:** `terragrunt destroy` y `./scripts/99_nuke_backend.sh`.
* **Qué hace:**
    1.  Elimina servidores y seguridad (Destroy).
    2.  Elimina el historial y el bucket S3 (Nuke).
* **Resultado:** Cuenta de AWS en estado "Tabula Rasa" (Limpia). Costo $0.

---
