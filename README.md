# 🏛️ AWS Enterprise Multi-Environment Architecture (Terragrunt + DRY)

![AWS](https://img.shields.io/badge/AWS-Cloud-orange?style=for-the-badge&logo=amazon-aws)
![Terragrunt](https://img.shields.io/badge/Terragrunt-DRY_Architecture-purple?style=for-the-badge)
![Terraform](https://img.shields.io/badge/Terraform-v1.10-blue?style=for-the-badge)
![FinOps](https://img.shields.io/badge/FinOps-Audited-green?style=for-the-badge)

> **"Don't Repeat Yourself" (DRY) llevada al extremo.**
> Este repositorio demuestra cómo orquestar una infraestructura escalable en 3 entornos (Dev, QA, Prod) utilizando un único código base y prácticas avanzadas de **FinOps** y **SecOps**.

---

## 🧠 El Problema vs. La Solución

| Enfoque Tradicional (Junior) ❌ | Enfoque Terragrunt (Senior) ✅ |
| :--- | :--- |
| Copiar `backend "s3"` en cada carpeta. | Definir el Backend **una sola vez** en la raíz. |
| Repetir código de recursos en Dev/Prod. | Usar **Módulos Reutilizables** inyectando variables. |
| Instalación manual de herramientas. | Script de **Auto-Instalación** de dependencias. |
| Costos fantasma por recursos olvidados. | Script de **Auditoría Forense** y **Nuke Backend** incluidos. |

---

## 🏗️ Estructura del Proyecto

```bash
.
├── live/                   # 🎮 IMPLEMENTACIÓN (El "Qué")
│   ├── terragrunt.hcl      # 🧠 Orquestador Padre (Backend S3 DRY)
│   ├── dev/                # Entorno Desarrollo (t3.micro, Puerto 8080)
│   ├── qa/                 # Entorno QA (Mirror de Prod)
│   └── prod/               # Entorno Producción (Etiquetado estricto)
│
├── modules/                # 🧩 LÓGICA (El "Cómo")
│   └── compute-instance/   # Módulo reutilizable de EC2 + Security Groups
│
└── scripts/                # 🛠️ AUTOMATIZACIÓN & FINOPS
    ├── 00_init_backend.sh    # Setup Idempotente del Backend S3 (Cifrado)
    ├── audit_finops.sh       # Auditoría de Costos (Detecta recursos del Repo)
    ├── install_terragrunt.sh # Instalador automático de versiones
    └── 99_nuke_backend.sh    # ☢️ Destrucción total del Backend S3 (Emergency)
```

---

## 🚀 Guía de Reproducción (Paso a Paso)

### 1. Prerrequisitos Automáticos
No necesitas buscar versiones ni pelear con binarios. El script detecta tu SO e instala Terragrunt automáticamente.

```bash
chmod +x scripts/*.sh
./scripts/install_terragrunt.sh
```

### 2. Cimientos de Seguridad (Backend)
Preparamos el bucket S3 con cifrado AES-256, bloqueo de acceso público y versionado para proteger el estado (tfstate).

```bash
./scripts/00_init_backend.sh
```
*(Importante: Copia el nombre del bucket generado y actualiza la línea `bucket = "..."` en el archivo `live/terragrunt.hcl`)*.

### 3. Despliegue Multi-Entorno
Gracias a la arquitectura modular, desplegar es trivial. Terragrunt genera los providers y backends necesarios al vuelo.

**Desarrollo (Dev):**
```bash
cd live/dev && terragrunt apply -auto-approve
```

**Calidad (QA):**
```bash
cd ../qa && terragrunt apply -auto-approve
```

**Producción (Prod):**
```bash
cd ../prod && terragrunt apply -auto-approve
```

---

## 💰 FinOps & Auditoría (El valor del dinero)
La nube es cara si no se vigila. Este proyecto incluye un **Auditor Forense** que escanea la cuenta buscando recursos (EC2, EBS, SG) etiquetados específicamente bajo este repositorio.

Ejecútalo para verificar qué está consumiendo dinero:

```bash
# Desde la raíz del proyecto
./scripts/audit_finops.sh
```

**Output esperado:**
```text
🔍 AUDITANDO RECURSOS DEL REPO: aws-terragrunt-enterprise-scale
----------------------------------------------------------------
Auditando Instancias EC2... ⚠️  ACTIVOS: i-0abc...
Auditando Volúmenes EBS...  ⚠️  ACTIVOS: vol-0xyz...
----------------------------------------------------------------
```
*(Si todo está apagado, dirá: ✅ LIMPIO)*

---

## 🧹 Destrucción Total (Clean Up)
Para evitar costos, sigue este orden estricto:

1. **Destruir infraestructura:**
```bash
cd live/prod && terragrunt destroy -auto-approve
cd ../qa && terragrunt destroy -auto-approve
cd ../dev && terragrunt destroy -auto-approve
```

2. **Verificar limpieza:**
```bash
./scripts/audit_finops.sh
```

3. **☢️ Nuke Backend (Opcional):**
Si deseas eliminar el Bucket S3 que contiene los estados (para evitar costos de almacenamiento de S3):
```bash
./scripts/99_nuke_backend.sh
```

---

<div align="center">

### 👨‍💻 Author & Maintainer

**Jorge Garagorry**
*Cloud System Administrator | DevOps Engineer*

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect_on_LinkedIn-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/jgaragorry/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow_@jgaragorry-181717?style=for-the-badge&logo=github)](https://github.com/jgaragorry)

<p><i>"Building reliable, scalable, and automated cloud infrastructure."</i></p>

**⭐ Don't forget to star this repo if you found the architecture useful! ⭐**

</div>
