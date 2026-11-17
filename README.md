# Sebasgova Edición - Flutter

**Autor:** Sebastián González Vanegas  
**Asignatura:** Lenguaje de Programación para APPs  
**Universidad:** UCC  
**Entrega:** Momento Evaluativo 2

## ¿De qué trata el proyecto?

Sebasgova Edición es una aplicación que estoy desarrollando para organizar mi trabajo como editor de videos freelance.

La idea nació porque normalmente manejo mis clientes, proyectos, pagos y tareas en diferentes aplicaciones, y a veces se vuelve complicado llevar el control de todo.

Por eso decidí crear una aplicación donde pueda tener toda esa información en un mismo lugar.

## ¿Qué quiero lograr?

Mi objetivo es tener una aplicación sencilla que me permita organizar mis proyectos, saber cuánto dinero he ganado, qué pagos tengo pendientes y cuáles son mis próximas entregas.

La aplicación está hecha con **Flutter y Dart**, tomando como base una página web que ya había desarrollado anteriormente.

También quiero que ambas versiones puedan compartir la misma información.

## ¿Qué tiene la aplicación?

Hasta ahora he trabajado en estas funciones:

- **Clientes:** agregar, buscar, editar y eliminar clientes.
- **Proyectos:** crear proyectos y organizarlos según su estado.
- **Pipeline:** llevar un seguimiento de posibles clientes.
- **Tareas:** organizar pendientes y marcar los que ya terminé.
- **Pagos:** registrar cuánto me han pagado por cada proyecto.
- **Finanzas:** controlar ingresos, gastos y dinero disponible en COP, USD y EUR.
- **Entregas:** revisar las fechas de entrega de mis trabajos.
- **Ajustes:** guardar información y hacer copias de seguridad en JSON.

También estoy trabajando en algunas gráficas para visualizar mejor mis ingresos.

## ¿Cómo va el proyecto?

Actualmente tengo **8 de las 14 funcionalidades terminadas**, lo que representa aproximadamente un **57 % de avance**.

Todavía me faltan algunas cosas, como las transferencias entre cuentas, un calendario mensual, personalizar algunas opciones y poder arrastrar proyectos entre etapas.

Estas funciones se irán agregando más adelante.


## Inventario de funcionalidades

| Funcionalidad | Estado | Evidencia |
|---|---|---|
| Clientes: crear, listar, buscar, filtrar, editar y eliminar | Completa | Clientes |
| Proyectos: etapas, ficha y CRUD | Completa | Proyectos y ficha |
| Pipeline: mover etapas y convertir prospectos | Completa | Pipeline |
| Tareas: prioridad, fecha, completar y filtrar | Completa | Pendientes |
| Pagos por proyecto y cuentas por cobrar | Completa | Proyecto y Finanzas |
| Ingresos, gastos y saldos multimoneda | Completa | Finanzas |
| Agenda de entregas | Completa | Entregas |
| Guardado local y respaldo JSON | Completa | Ajustes |
| Gráfica mensual | En desarrollo | Finanzas > Resumen |
| Transferencias y comisiones | Pendiente | Finanzas |
| Videos y lotes mensuales | Pendiente | Ficha de proyecto |
| Etapas y cuentas personalizables | Pendiente | Ajustes |
| Arrastrar y soltar en tableros | Pendiente | Proyectos |
| Calendario mensual | Pendiente | Entregas |

**Avance declarado: 8 de 14 funcionalidades completas (57 %).**

## ¿Cómo ejecutar la aplicación?

Para abrir el proyecto es necesario tener Flutter instalado.

Desde la terminal, dentro de la carpeta del proyecto, se ejecutan estos comandos:

```bash
flutter pub get
flutter run -d chrome
```

Si es la primera vez que se abre el proyecto y todavía no están creadas las carpetas de Android o web, primero se ejecuta:

```bash
flutter create . --platforms=web,android
```

La aplicación se puede probar en Chrome o en un dispositivo Android.

También tiene una opción en **Ajustes > Datos de ejemplo** para agregar información de prueba sin tener que crear todo manualmente.

## Organización del proyecto

Organicé el código en diferentes carpetas para que sea más fácil trabajar y encontrar cada parte:

- **models:** información de clientes, proyectos, pagos y tareas.
- **screens:** pantallas principales de la aplicación.
- **forms:** formularios para agregar y editar información.
- **widgets:** elementos que se repiten en varias pantallas.
- **theme:** colores, textos y estilos de la aplicación.
- **services:** funciones para guardar y administrar los datos.
- **core:** configuraciones y funciones generales.
- **test:** pruebas para comprobar que algunas funciones trabajen correctamente.

## Diseño y navegación

Para el diseño utilicé los mismos colores y estilos de mi aplicación web, buscando que ambas versiones se vieran similares.

La aplicación tiene un menú para entrar a las diferentes secciones. También adapté la navegación para que se pueda utilizar tanto en computador como en celular.

Las funciones que todavía no están terminadas aparecen con el aviso **"Próximamente"**.

## Guardado de información

Los datos se guardan directamente en el dispositivo o navegador, por lo que no es necesario tener una cuenta ni conectarse a un servidor.

También agregué la posibilidad de exportar y cargar archivos JSON para respaldar la información y compartirla con la versión web.

## ¿Qué sigue para el Momento 3?

Para la siguiente entrega tengo pensado:

1. Agregar transferencias entre cuentas.
2. Mejorar la organización de proyectos mensuales.
3. Permitir personalizar etapas y cuentas.
4. Agregar un calendario mensual.
5. Mejorar las gráficas de finanzas.
6. Terminar algunas funciones pendientes.

## Conclusión

Este proyecto lo estoy desarrollando a partir de una necesidad real de mi trabajo como editor de videos.

Aunque todavía faltan algunas funcionalidades, ya puedo utilizar la aplicación para organizar clientes, proyectos, tareas, pagos y entregas.

Mi idea es seguir mejorándola para que no sea solamente un trabajo de la universidad, sino una herramienta que pueda utilizar en mi día a día.