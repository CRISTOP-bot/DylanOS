# Registro técnico de cambios: CI, instalador, staging, panel y dock

**Rama de trabajo:** `development` exclusivamente.  
**Alcance:** se registran los commits existentes y los cambios hechos durante la reparación de CI y el launcher del dock. No se modificó ni fusionó `main`.

## Cambios documentados

| Commit | Motivo y cambio | Archivos / tipo de cambio | Verificación disponible |
|---|---|---|---|
| `7f09bad10d0e0572e6b5de85061086eba1758041` | El widget de la aplicación activa del panel superior podía truncar nombres largos. Se aumentó el ancho mínimo y se ancló a ambos extremos la fila de etiqueta para aprovechar el espacio disponible. | `apps/com.dylanos.activeapp/contents/ui/main.qml` — ajuste QML de dimensiones y anclaje. | El commit documenta la corrección visual; el CI que corrió entonces no sirve como validación final porque falló después en un test ajeno, que se corrigió en `ffe5f708`. |
| `4ba500f25c69f635fae0d9dcafe5a4c660fc71e1` | Se dejó constancia de la corrección del widget y su contexto para que no dependa solo del cambio de código. | `docs/correcciones-live-x11-instalador-appcenter-2026-10-13.md` — documentación, sección 7.7. | Cambio documental. |
| `ffe5f708bb4e9e19235c376aa7e0157058706101` | El test de Explorer exigía un ZIP que no estaba rastreado ni aparecía en el historial. Se cambió la comprobación para validar los tres PNG de referencia que sí existen en el repositorio. | `scripts/tests/test_explorer.py` — corrección de fixture/expectativas del test. | El test de Explorer pasó en el CI final registrado abajo: 9 tests, `OK`. |
| `f67bcc7e101c9c308f819324270074da4e725f27` | Un checkout limpio no contiene `installer/dylanos-installer/dist`; hacía falta construir el bundle real antes de copiarlo al staging. Se añadió un helper de build Vite y se integró en las rutas de build y de CI; se añadió Node 22 a los workflows. | `.github/workflows/build.yml`, `.github/workflows/lint.yml` — configuración CI; `scripts/build-installer.sh` — nuevo helper `npm ci` + Vite build y validación de `dist/index.html`; `scripts/build.sh`, `scripts/check.sh` — wiring; `scripts/tests/test_staging.py` — cobertura de la integración; `docs/architecture.md` — documentación. | El CI final confirmó el build real de Vite (`✓ built`) y la suite de staging. No se presenta como build local: el entorno local no tenía Node/npm. |
| `fd75e280de932a0e77c65a6757801fe1ff9baab3` | `stage.py` hacía `os.chown(..., 1000, 1000)` en un runner sin privilegios. El cambio conserva el ownership esperado en builds ejecutados como root y omite el `chown` solo en staging rootless. | `scripts/stage.py` — guarda por UID efectivo; `docs/architecture.md` — explicación del comportamiento. | La suite `test_staging` pasó en el CI final (4 tests). El run `39713236565` no falló por `chown`: llegó a `test_store` y falló porque faltaba otra lista de paquetes, corregida en `e3ae206`. |
| `e3ae20621a39d7b1e061ff725fe3660844c39192` | `scripts/build.sh` ya usaba el grupo `build` y el test de Store verificaba sus dependencias, pero el archivo de lista faltaba en el repositorio. Se restauró una lista real con toolchain/CMake/Qt/KDE y dependencias de compilación de la tienda. | `packages/build/packages.list` — nueva lista de dependencias de build. | El run **39713439164** para este commit concluyó `success`: https://github.com/CRISTOP-bot/DylanOS/actions/runs/39713439164. |
| `69f1bd44b29b22035163caf5ec7634ba55468de2` | El layout del dock apuntaba a `applications:codium.desktop`, pero VSCodium solo estaba en el perfil opcional `development`; el perfil base podía dejar el launcher sin aplicación ni icono. Se incluyó `codium` en el perfil base para que el dock tenga una app instalada que resolver. | `packages/default/packages.list` — añade VSCodium (compatible con VS Code) al perfil base. | El test añadido en `5e9ac7d` comprueba que el launcher declarado existe en la lista del perfil base. |
| `a58b80cd0e490a677b2a65450f1ee5cd2841f4e1` | El paquete `codium` necesita su repositorio apt externo; se añadió el setup al grupo base para que la instalación sea válida también sin seleccionar `development`. | `packages/default/setup-repos.sh` — configura llave y repositorio VSCodium antes de instalar paquetes. | `bash -n` sobre los scripts y la suite completa de `scripts/check.sh` pasaron en el run final. No se ejecutó una build ISO completa. |
| `5e9ac7dae8c163ab931599012433a264afa6086c` | Se añadió una prueba de regresión para el launcher predeterminado del dock: verifica el desktop ID `codium.desktop`, rechaza el ID roto `code.desktop`, y exige tanto el paquete base `codium` como su setup de repositorio. | `scripts/tests/test_dock_launcher.py` — nuevo test unittest. | En CI, `test_dock_launcher` ejecutó 1 test y terminó `OK`. |

## Historial de CI y resultado verificable

1. **Run 39713236565**, commit `fd75e280de932a0e77c65a6757801fe1ff9baab3`: `failure`. La compilación de Vite terminó correctamente, pasaron 39 validaciones y las suites anteriores a Store; la causa final fue `FileNotFoundError` al leer `packages/build/packages.list` en `StoreStructureTest.test_packages_and_build_wiring`. No se atribuye este fallo al ajuste de `chown`.
2. **Run 39713439164**, commit `e3ae20621a39d7b1e061ff725fe3660844c39192`: `success` tras restaurar `packages/build/packages.list`.
3. **Run 39713723823**, HEAD técnico `5e9ac7dae8c163ab931599012433a264afa6086c`: `success`. En el log: build Vite completado; 39 validaciones, 0 fallos; `test_dock_launcher` pasó (1 test), `test_explorer` pasó (9), `test_staging` pasó (4) y `test_store` pasó (15); las comprobaciones finales de código, datos, staging y carga QML terminaron `OK`. La suite `test_gtk_runtime` reportó dos skips opcionales; no se cuentan como pruebas ejecutadas.

Enlace del run: https://github.com/CRISTOP-bot/DylanOS/actions/runs/39713723823

**Límite de verificación:** se validó el workflow CI de lint/check indicado; no se ejecutó localmente una ISO ni se afirma que el ISO arranque a partir de estas pruebas. Tampoco se afirma que se haya compilado localmente: el entorno local no tenía `git`, `node`, `npm` ni `shellcheck`.

## Protección de `main`

La rama `main` no recibió commits ni merges. En la última comprobación anterior a este registro apuntaba a `092327b382979a54a12b28bf156bafd5d8f17069`; el trabajo y los workflows citados corresponden a `development`.
