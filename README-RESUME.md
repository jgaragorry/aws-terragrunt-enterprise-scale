# 🧠 Resumen Ejecutivo y Arquitectura del Proyecto

Este documento sirve como guía rápida conceptual y base de conocimiento para entender el "Por qué" y el "Cómo" de esta arquitectura multi-entorno.

---

## 🎯 Definición del Perfil Profesional

Este laboratorio demuestra competencias clave para el rol de:

👉 **Cloud Engineer | DevOps & SRE**

> *Profesional capaz no solo de administrar sistemas en la nube (SysAdmin), sino de automatizar su ciclo de vida completo mediante código (DevOps) y garantizar la fiabilidad del sitio (SRE), diseñando soluciones escalables, seguras y eficientes.*

---

## 💡 Conceptos Clave (Resumen Rápido)

### 1. ¿Por qué este Laboratorio? (El Problema)
Terraform "puro" (Vanilla) tiene una limitación crítica: no permite usar variables en la configuración del Backend (donde se guarda el estado remoto `tfstate`).
* **Consecuencia:** Para tener 3 entornos (Dev, QA, Prod), debes copiar y pegar el mismo bloque de código 3 veces. Esto viola el principio DRY (Don't Repeat Yourself) y es propenso a errores humanos catastróficos (ej. sobrescribir Prod con Dev).

### 2. La Solución: Terragrunt como Orquestador
Terragrunt actúa como un "wrapper" (envoltorio) inteligente sobre Terraform.
* **Backend Dinámico:** Definimos la configuración de S3 una sola vez en la raíz. Terragrunt la inyecta automáticamente en cada entorno, generando las rutas correctas (`dev/`, `prod/`).
* **Código DRY:** Mantenemos la lógica de infraestructura (Módulos) separada de la configuración específica de cada entorno (Live).

### 3. ¿Es esto "Enterprise Grade"? (Grado Empresarial)
**SÍ.** No por el tamaño, sino por la madurez y seguridad de la arquitectura:
* ✅ **Aislamiento:** Cada entorno tiene su propio archivo de estado (`tfstate`) separado. Un error en Dev no rompe Prod.
* ✅ **Seguridad (SecOps):** El Backend S3 está cifrado (AES-256) y bloqueado al público.
* ✅ **Modularidad:** Uso de módulos reutilizables en lugar de código monolítico.
* ✅ **Auditoría (FinOps):** Scripts integrados para control de costos y limpieza de recursos.

### 4. Tu "Elevator Pitch" (Discurso Rápido)
> *"Diseñé esta arquitectura para simular un escenario real de alta escala donde Terraform nativo se queda corto. Utilicé Terragrunt para garantizar una infraestructura 100% inmutable y DRY, donde la seguridad del backend se hereda automáticamente y el despliegue de múltiples entornos se gestiona desde un único código base, reduciendo la carga operativa y el riesgo humano."*

---

## 🔄 Diagrama de Flujo de la Arquitectura

Este diagrama muestra cómo se mueven los datos desde tu laptop hasta convertirse en infraestructura real en AWS.

```mermaid
graph TD
    %% Definición de Nodos
    User[🧑‍💻 Ingeniero DevOps<br>(Laptop Local)]
    
    subgraph "Fase 1: Bootstrapping & Config"
        Scripts[🛠️ Scripts de Automatización<br>(install_tg.sh, 00_init.sh)]
        BackendConfig[📝 terragrunt.hcl<br>(Raíz: Config Backend S3)]
    end
    
    subgraph "Fase 2: Orquestación (Terragrunt)"
        TG_Dev[🧠 Terragrunt DEV<br>(live/dev/terragrunt.hcl)]
        TG_Prod[🧠 Terragrunt PROD<br>(live/prod/terragrunt.hcl)]
        Modules[📦 Módulos Terraform<br>(modules/compute-instance/)]
    end
    
    subgraph "Fase 3: AWS Cloud (Infrastructure)"
        S3_Backend[(🪣 AWS S3 Backend<br>Cifrado + Locking)]
        
        subgraph "Entorno DEV (us-east-1)"
            EC2_Dev[🖥️ EC2 t3.micro<br>(Tags: Junior, Puerto 8080)]
        end
        
        subgraph "Entorno PROD (us-east-1)"
            EC2_Prod[🖥️ EC2 t3.micro<br>(Tags: SRE, Puerto 80)]
        end
    end
    
    FinOps[💰 Auditoría FinOps<br>(audit_finops.sh)]

    %% Flujo de Datos
    User -->|1. Ejecuta| Scripts
    Scripts -->|Crea| S3_Backend
    
    User -->|2. 'terragrunt apply'| TG_Dev
    User -->|2. 'terragrunt apply'| TG_Prod
    
    TG_Dev -->|Inyecta Variables| Modules
    TG_Prod -->|Inyecta Variables| Modules
    BackendConfig -.->|Hereda Config| TG_Dev
    BackendConfig -.->|Hereda Config| TG_Prod
    
    Modules -->|3. Llama API AWS| EC2_Dev
    Modules -->|3. Llama API AWS| EC2_Prod
    
    TG_Dev -.-|Guarda Estado (dev/tfstate)| S3_Backend
    TG_Prod -.-|Guarda Estado (prod/tfstate)| S3_Backend
    
    User -->|4. Verifica| FinOps
    FinOps -->|Escanea Tags| EC2_Dev
    FinOps -->|Escanea Tags| EC2_Prod
```

---

<div align="center">

### 👤 Connect with the Author

**Jorge Garagorry**
<br>
*Cloud Engineer | DevOps & SRE*

<p>
  <a href="https://www.linkedin.com/in/jgaragorry/">
    <img src="https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin" alt="LinkedIn"/>
  </a>
  <a href="https://github.com/jgaragorry">
    <img src="https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github" alt="GitHub"/>
  </a>
</p>

<p>
  <a href="https://www.geekmonkeytech.com">
    <img src="https://img.shields.io/badge/Portafolio-GeekMonkeyTech-ff69b4?style=for-the-badge&logo=coderwall" alt="Portfolio"/>
  </a>
  <a href="https://www.softraincorp.com">
    <img src="https://img.shields.io/badge/Web-SoftRainCorp-blue?style=for-the-badge&logo=google-cloud" alt="Website"/>
  </a>
</p>

<p>
  <a href="https://chat.whatsapp.com/ENuRMnZ38fv1pk0mHlSixa">
    <img src="https://img.shields.io/badge/WhatsApp-Join_Community-25D366?style=for-the-badge&logo=whatsapp" alt="WhatsApp"/>
  </a>
  <a href="https://www.tiktok.com/@softtraincorp">
    <img src="https://img.shields.io/badge/TikTok-@softtraincorp-000000?style=for-the-badge&logo=tiktok" alt="TikTok"/>
  </a>
</p>

<p><i>"Transforming complex infrastructure into simple, automated code."</i></p>

</div>
