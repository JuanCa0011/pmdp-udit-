package com.example.filtro400

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

/**
 * Repositorio de datos que gestiona la base de datos SQLite mediante SQLiteOpenHelper.
 * Implementa un patrón Singleton, inicialización de semilla ("400"), operaciones CRUD
 * y una caché en memoria (@Volatile) de alto rendimiento para el CallScreeningService.
 */
class FiltroRepository private constructor(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    init {
        refreshCache() // Carga inicial de la caché al instanciar el repositorio.
    }

    companion object {
        const val DATABASE_NAME = "filtros.db"
        const val DATABASE_VERSION = 1

        const val TABLE_FILTRO = "filtro"
        const val COLUMN_ID = "id"
        const val COLUMN_PREFIJO = "prefijo"
        const val COLUMN_ACTIVO = "activo"
        const val COLUMN_CREADO_EN = "creado_en"

        @Volatile
        private var INSTANCE: FiltroRepository? = null

        /**
         * Obtiene la única instancia (Singleton) del repositorio de forma segura para hilos (thread-safe).
         */
        fun getInstance(context: Context): FiltroRepository {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: FiltroRepository(context.applicationContext).also { INSTANCE = it }
            }
        }
    }

    // Caché en memoria de filtros activos para lectura instantánea sin bloquear la UI ni la llamada.
    @Volatile
    private var cachedActiveFilters: List<String> = emptyList()

    /**
     * Se ejecuta cuando se crea la base de datos por primera vez. Crea la tabla e inserta la semilla "400".
     */
    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE $TABLE_FILTRO (
                $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_PREFIJO TEXT NOT NULL UNIQUE,
                $COLUMN_ACTIVO INTEGER NOT NULL DEFAULT 1,
                $COLUMN_CREADO_EN INTEGER NOT NULL
            )
            """.trimIndent()
        )
        // Inserción del filtro por defecto "400" en la primera instalación.
        val values = ContentValues().apply {
            put(COLUMN_PREFIJO, "400")
            put(COLUMN_ACTIVO, 1)
            put(COLUMN_CREADO_EN, System.currentTimeMillis())
        }
        db.insert(TABLE_FILTRO, null, values)
    }

    /**
     * Gestiona las actualizaciones de esquema de la base de datos.
     */
    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_FILTRO")
        onCreate(db)
    }

    /**
     * Consulta SQLite para refrescar la caché en memoria con los prefijos que tienen activo = 1.
     */
    private fun refreshCache() {
        val activeList = mutableListOf<String>()
        val db = readableDatabase
        val cursor = db.query(
            TABLE_FILTRO,
            arrayOf(COLUMN_PREFIJO),
            "$COLUMN_ACTIVO = 1",
            null, null, null, null
        )
        cursor.use {
            while (it.moveToNext()) {
                val pref = it.getString(it.getColumnIndexOrThrow(COLUMN_PREFIJO))
                activeList.add(pref)
            }
        }
        cachedActiveFilters = activeList
    }

    /**
     * Devuelve los filtros activos para el servicio de llamadas utilizando la caché en memoria.
     */
    fun getActiveFiltersForService(): List<String> {
        if (cachedActiveFilters.isEmpty()) {
            synchronized(this) {
                if (cachedActiveFilters.isEmpty()) {
                    refreshCache()
                }
            }
        }
        return cachedActiveFilters
    }

    /**
     * Recupera todos los filtros registrados (activos e inactivos) ordenados por fecha descendente.
     */
    fun getAllFilters(): List<FiltroItem> {
        val list = mutableListOf<FiltroItem>()
        val db = readableDatabase
        val cursor = db.query(TABLE_FILTRO, null, null, null, null, null, "$COLUMN_CREADO_EN DESC")
        cursor.use {
            while (it.moveToNext()) {
                val id = it.getLong(it.getColumnIndexOrThrow(COLUMN_ID))
                val prefijo = it.getString(it.getColumnIndexOrThrow(COLUMN_PREFIJO))
                val activo = it.getInt(it.getColumnIndexOrThrow(COLUMN_ACTIVO)) == 1
                val creadoEn = it.getLong(it.getColumnIndexOrThrow(COLUMN_CREADO_EN))
                list.add(FiltroItem(id, prefijo, activo, creadoEn))
            }
        }
        return list
    }

    /**
     * Inserta un nuevo filtro validado en la base de datos y actualiza la caché.
     */
    fun insertarFiltro(prefijo: String): Result<Long> {
        val validation = MotorFiltrado.validarPrefijo(prefijo)
        if (validation.isFailure) return Result.failure(validation.exceptionOrNull()!!)
        val limpio = validation.getOrThrow()

        val db = writableDatabase
        val values = ContentValues().apply {
            put(COLUMN_PREFIJO, limpio)
            put(COLUMN_ACTIVO, 1)
            put(COLUMN_CREADO_EN, System.currentTimeMillis())
        }
        return try {
            val id = db.insertOrThrow(TABLE_FILTRO, null, values)
            refreshCache()
            Result.success(id)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Actualiza el prefijo o estado de un filtro existente.
     */
    fun actualizarFiltro(id: Long, prefijo: String, activo: Boolean): Result<Unit> {
        val validation = MotorFiltrado.validarPrefijo(prefijo)
        if (validation.isFailure) return Result.failure(validation.exceptionOrNull()!!)
        val limpio = validation.getOrThrow()

        val db = writableDatabase
        val values = ContentValues().apply {
            put(COLUMN_PREFIJO, limpio)
            put(COLUMN_ACTIVO, if (activo) 1 else 0)
        }
        return try {
            val rows = db.update(TABLE_FILTRO, values, "$COLUMN_ID = ?", arrayOf(id.toString()))
            if (rows > 0) {
                refreshCache()
                Result.success(Unit)
            } else {
                Result.failure(Exception("Filtro no encontrado"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Cambia el estado de activación (Switch) de un filtro y actualiza la caché instantáneamente.
     */
    fun toggleFiltro(id: Long, activo: Boolean): Result<Unit> {
        val db = writableDatabase
        val values = ContentValues().apply {
            put(COLUMN_ACTIVO, if (activo) 1 else 0)
        }
        return try {
            val rows = db.update(TABLE_FILTRO, values, "$COLUMN_ID = ?", arrayOf(id.toString()))
            if (rows > 0) {
                refreshCache()
                Result.success(Unit)
            } else {
                Result.failure(Exception("Filtro no encontrado"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Elimina un filtro de la base de datos por su identificador único.
     */
    fun eliminarFiltro(id: Long): Result<Unit> {
        val db = writableDatabase
        return try {
            val rows = db.delete(TABLE_FILTRO, "$COLUMN_ID = ?", arrayOf(id.toString()))
            if (rows > 0) {
                refreshCache()
                Result.success(Unit)
            } else {
                Result.failure(Exception("Filtro no encontrado"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
