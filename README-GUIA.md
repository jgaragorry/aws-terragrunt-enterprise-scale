# 📘 GUÍA MAESTRA DE EJECUCIÓN (RUNBOOK)
> **Objetivo:** Despliegue y destrucción total de arquitectura Multi-Entorno con Terragrunt.
> **Tiempo estimado:** 15 minutos.
> **Costo:** $0.00 (Si se completa la Fase 5).

---

## 🏁 Fase 0: Preparación del Entorno
*Asegúrate de tener AWS CLI configurado (`aws configure`) antes de empezar.*

### 1. Clonar y dar permisos
Descargamos el código y hacemos ejecutables los scripts de automatización.

```bash
git clone [https://github.com/jgaragorry/aws-terragrunt-enterprise-scale.git](https://github.com/jgaragorry/aws-terragrunt-enterprise-scale.git)
cd aws-terragrunt-enterprise-scale
chmod +x scripts/*.sh
```

### 2. Instalación de Herramientas (Auto-Magic)
No instales nada manualmente. Este script detecta si te falta Terragrunt y lo instala automáticamente.

```bash
./scripts/install_terragrunt.sh
```

---

## 🛡️ Fase 1: Cimientos (Backend S3)
*Terraform necesita un "cerebro" (state) guardado en la nube.*

### 1. Crear el Bucket Seguro
Este script crea un bucket único con cifrado y bloqueo de acceso público.

```bash
./scripts/00_init_backend.sh
```

### 🛑 2. CONFIGURACIÓN MANUAL (CRÍTICO)
El script anterior te dio un nombre de bucket al final (ej: `terragrunt-enterprise-state-12345...`).
1.  Copia ese nombre.
2.  Abre el archivo `live/terragrunt.hcl`.
3.  Pégalo en la línea: `bucket = "PEGA_TU_BUCKET_AQUI"`.
4.  Guarda el archivo.

---

## 🚀 Fase 2: El Despliegue (Terragrunt Magic)
*Vamos a crear 3 entornos aislados usando el mismo código base.*

### 1. Desplegar DEV (Desarrollo)
Entorno pequeño (t3.micro), puerto 8080.

```bash
cd live/dev
terragrunt apply -auto-approve
```
*(Espera a ver la IP pública verde al final)*.

### 2. Desplegar QA (Calidad)
Espejo de producción, puerto 80.

```bash
cd ../qa
terragrunt apply -auto-approve
```

### 3. Desplegar PROD (Producción)
Entorno crítico, etiquetado estricto de Compliance.

```bash
cd ../prod
terragrunt apply -auto-approve
```

---

## 💰 Fase 3: Auditoría (La Prueba de Fuego)
*Verificamos qué está realmente corriendo y gastando dinero.*

Regresa a la raíz y corre el auditor:

```bash
cd ../..
./scripts/audit_finops.sh
```

**✅ Resultado Esperado:** Debes ver una lista de recursos con alerta **⚠️ ACTIVOS** (Instancias, Volúmenes y Security Groups). Esto confirma que todo está vivo.

---

## 🧹 Fase 4: Destrucción Controlada
*Apagamos los servidores para detener el cobro por hora de EC2.*

### 1. Destruir en orden de criticidad

```bash
# Matar Producción
cd live/prod
terragrunt destroy -auto-approve

# Matar QA
cd ../qa
terragrunt destroy -auto-approve

# Matar Desarrollo
cd ../dev
terragrunt destroy -auto-approve
```

### 2. Verificar Limpieza
Regresa a la raíz y audita de nuevo.

```bash
cd ../..
./scripts/audit_finops.sh
```

**✅ Resultado Esperado:** Debe decir explícitamente **"LIMPIO (0 recursos)"**.

---

## ☢️ Fase 5: Nuke (Eliminación Total)
*Eliminamos el historial y el bucket S3 para evitar cobros de almacenamiento.*

Este script es irreversible. Borra todas las versiones del `tfstate` y elimina el bucket.

```bash
./scripts/99_nuke_backend.sh
```

**✅ Resultado Final:** "BACKEND DESTRUIDO". Tu cuenta de AWS está exactamente igual que como la encontraste.

---
**🎉 FIN DEL LABORATORIO**
