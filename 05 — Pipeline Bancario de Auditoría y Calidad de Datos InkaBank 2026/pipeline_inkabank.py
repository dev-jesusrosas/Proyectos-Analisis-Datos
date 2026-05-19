import pandas as pd

print("  PIPELINE BANCARIO Y CALIDAD DE DATOS (EDX) - INKA_BANK")

# FASE 1: ETL (INGESTA)

print("[INFO] Cargando transacciones de los canales digitales...")
df_raw = pd.read_csv('transacciones_sucias.csv')

print(f"[ÉXITO] Archivo cargado. Registros iniciales: {len(df_raw)} filas.")
print("\n--- VISTA PREVIA DE LA DATA BANCARIA CRUDA ---")
print(df_raw)
print("-" * 50 + "\n")



# FASE 2: CALIDAD DE DATOS (DEDUPLICACIÓN)

print("[INFO] Purgando réplicas de transacciones de la RAM (Evitar doble cobro)...")
df_dedup = df_raw.drop_duplicates(keep='first')

print(f"[ÉXITO] Duplicados eliminados. Registros actuales: {len(df_dedup)} filas.")
print("-" * 50 + "\n")



# FASE 3: TRATAMIENTO DE NULOS Y ESTANDARIZACIÓN

print("[INFO] Homologando formatos de tiempo y corrigiendo saldos nulos...")
df_limpio = df_dedup.copy()

# Reemplazamos montos nulos por 0.0 (Como COALESCE en SQL)
df_limpio['monto_pen'] = df_limpio['monto_pen'].fillna(0.0)

# Convertimos las fechas a formato estándar internacional YYYY-MM-DD
df_limpio['fecha_operacion'] = pd.to_datetime(df_limpio['fecha_operacion'], errors='coerce')

# Rellenamos fechas vacías con la fecha de cierre de caja (2026-05-18)
df_limpio['fecha_operacion'] = df_limpio['fecha_operacion'].fillna(pd.to_datetime('2026-05-18'))

print("[ÉXITO] Formatos estandarizados y nulos corregidos.")
print("-" * 50 + "\n")



# FASE 4: AUDITORÍA DE RIESGOS (CONSISTENCIA LÓGICA)

print("[INFO] Validando consistencia e integridad financiera (Montos > 0)...")
df_auditado = df_limpio[df_limpio['monto_pen'] > 0]

print(f"[ÉXITO] Auditoría completada. Registros válidos para contabilidad: {len(df_auditado)} filas.")
print("-" * 50 + "\n")



# FASE 5: CONSOLIDACIÓN CON EL CORE BANCARIO (LEFT JOIN)

print("[INFO] Cruzando transacciones con el Maestro de Clientes (Enriquecimiento)...")
df_clientes = pd.read_csv('maestro_clientes.csv')

# Unimos las transacciones validadas con los nombres de los clientes
df_final = pd.merge(df_auditado, df_clientes, on='id_cliente', how='left')

print(f"[ÉXITO] Cruce relacional finalizado.")
print("-" * 50 + "\n")



# FASE 6: EXPORTACIÓN PARA CONCILIACIÓN (CARGA)

print("[INFO] Exportando set de datos conciliado para el área de Riesgos y Power BI...")
df_final.to_csv('auditoria_final_banco.csv', index=False)

print("\n" + "="*60)
print("--- REPORTE FINAL DE AUDITORÍA BANCARIA COMPLETO (DATA FINAL) ---")
print("="*60)
print(df_final)
print("="*60)
print("[ÉXITO] Proceso automatizado finalizado. Archivo 'auditoria_final_banco.csv' creado.")
print("="*60)