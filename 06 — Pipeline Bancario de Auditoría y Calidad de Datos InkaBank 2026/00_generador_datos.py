import pandas as pd


print("= LAB BANCARIO: GENERANDO ARCHIVOS CRUDOS DE CAJEROS (SUCIOS) =")


# 1. Simulamos transacciones de tarjetas con duplicados, nulos y montos negativos
data_transacciones_sucias = {
    'id_transaccion': [9001, 9002, 9003, 9001, 9004, 9005, 9006], 
    'id_cliente': ['CLI_101', 'CLI_102', 'CLI_101', 'CLI_101', 'CLI_999', 'CLI_103', 'CLI_102'],
    'tipo_operacion': ['Retiro', 'Depósito', 'Retiro', 'Retiro', 'Transferencia', 'Retiro', 'Depósito'],
    'monto_pen': [500.00, None, 500.00, 500.00, 1200.00, -50.00, 350.00], # Contiene un Nulo (None) y un Negativo
    'fecha_operacion': ['2026-05-18', '2026/05/18', '2026-05-18', '2026-05-18', '2026-05-19', '2026-05-19', None] # Errores de formato y un vacío
}

# 2. Tabla maestra de clientes (Base de datos central del Core Bancario)
data_clientes = {
    'id_cliente': ['CLI_101', 'CLI_102', 'CLI_103', 'CLI_104'],
    'nombre_cliente': ['Jesús Quispe', 'María Mendoza', 'Carlos Alcázar', 'Juan Pérez']
}

# 3. Exportación automática a archivos físicos CSV
pd.DataFrame(data_transacciones_sucias).to_csv('transacciones_sucias.csv', index=False)
pd.DataFrame(data_clientes).to_csv('maestro_clientes.csv', index=False)

print("\n[ÉXITO] Archivos generados en tu carpeta local:")
print(" -> 'transacciones_sucias.csv' (Simulación Core de Cajeros Corrupto)")
print(" -> 'maestro_clientes.csv' (Catálogo Central de Clientes)")
print("==================================================================\n")