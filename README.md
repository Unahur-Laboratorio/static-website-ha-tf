# Sitio estatico HA con Terraform

Practica de alta disponibilidad en AWS: VPC propia, dos subnets publicas en AZ diferentes, dos EC2 con Apache y un ALB publico. No usa la VPC default. Se crean 16 recursos Terraform.

## Requisitos

- Terraform >= 1.5 y < 2, Git y AWS CLI.
- Credenciales temporales de Learner Lab vigentes, incluido el token de sesion. No incluirlas en este repositorio ni en variables Terraform.
- AMI `staticweb-ami` creada en la practica manual, con Apache habilitado y el sitio publicado. Terraform no crea ni elimina esa AMI.
- Key pair existente en la misma region, AMI x86_64 y un tipo de instancia compatible permitido por el laboratorio.
- Dos AZ disponibles de la region elegida.

Cada alumno trabaja en su cuenta de laboratorio. No ejecutar dos copias independientes en la misma cuenta y region con estos mismos nombres: pueden colisionar con recursos existentes. El ALB manual `ha-alb` y el Target Group `ha-tg` deben haberse eliminado antes de este despliegue. Terraform no adopta automaticamente recursos creados manualmente.

## Obtener una copia

Cuando el docente publique este repositorio, clonar la URL que proporcione:

```bash
git clone <URL_DEL_REPOSITORIO> static-website-ha-tf
cd static-website-ha-tf
cp terraform.tfvars.example terraform.tfvars
```

Editar `terraform.tfvars`: reemplazar AMI ID y nombre del key pair. Si se cambia la region, ajustar tambien las AZ, AMI y key pair.

Las EC2 permiten HTTP 80 y SSH 22 desde `0.0.0.0/0`; el ALB permite HTTP 80 desde ese mismo origen. Esta apertura se usa solo para el laboratorio. En produccion, restringir SSH al origen administrativo y HTTP de las EC2 al Security Group del ALB.

```bash
aws sts get-caller-identity
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
terraform output -raw alb_url
```

Revisar el plan antes de confirmar. Los comandos `plan`, `apply` y `destroy` requieren credenciales vigentes. No subir el state, planes, claves PEM ni `terraform.tfvars`. El lockfile `.terraform.lock.hcl` se conserva en Git para fijar la version del provider.

## Archivos

| Archivo | Funcion |
| --- | --- |
| `main.tf` | Versiones y provider AWS |
| `variables.tf` | Parametros de la practica |
| `redes.tf` | VPC, IGW, subnets, rutas y asociaciones |
| `security_groups.tf` | HTTP publico al ALB; HTTP y SSH publicos a las EC2 |
| `instancias.tf` | Las dos EC2, inicialmente sin User Data |
| `load_balancer.tf` | ALB, listener, Target Group y registro de EC2 |
| `outputs.tf` | IDs, direcciones y URL |
| `instance_info.sh` | Personalizacion para la segunda etapa |

## Etapa 1: Validar el despliegue inicial

Esperar a que `ha-alb` este Active y ambos targets de `ha-tg` aparezcan healthy. Abrir la URL con `http://`, no HTTPS. Apache y el sitio deben venir instalados en la AMI; inicialmente se muestra el HTML base.

Si hay timeout con targets healthy, revisar que el ALB tenga `ha-alb-sg`, entrada TCP 80 desde Internet y listener HTTP:80 hacia `ha-tg`. Las casillas de seleccion de targets no indican si estan registrados.

## Etapa 2: Modificar la infraestructura

En ambos recursos de `instancias.tf`, agregar:

```hcl
user_data                   = file("${path.module}/instance_info.sh")
user_data_replace_on_change = true
```

```bash
terraform fmt
terraform plan
terraform apply
```

Revisar que el plan proponga reemplazar las EC2: User Data debe ejecutarse en el primer arranque de las nuevas instancias. Esta actualizacion puede interrumpir temporalmente el servicio; no demuestra despliegue sin interrupciones.

Abrir `http://DNS_DEL_ALB/instance-info.html` para ver hostname, IP privada, ID y AZ. El script ya esta incluido: no hace falta volver a crearlo. Refrescar o realizar varias solicitudes puede mostrar ambos destinos, aunque no se garantiza alternancia estricta en cada recarga.

Desde la consola detener una de las EC2, esperar los health checks y comprobar que la otra sigue respondiendo. Volver a iniciarla y esperar que recupere el estado healthy. No hay Auto Scaling: una instancia detenida no se reemplaza automaticamente.

## Limpiar

```bash
terraform destroy
```

Elimina los recursos administrados por este proyecto, no la AMI ni el key pair preexistentes. No borrar el state antes de destruir. EC2, ALB, IPv4 publicas y almacenamiento pueden generar cargos; conservar la AMI tambien conserva sus snapshots facturables.