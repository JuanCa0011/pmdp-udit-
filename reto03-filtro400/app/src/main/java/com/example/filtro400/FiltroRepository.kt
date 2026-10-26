package com.example.filtro400

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

/**
 * Repositorio ampliado para la Fase 3: gestiona tablas de prefijos con prioridad,
 * números bloqueados exactos, listas blancas y registro de actividad con enmascaramiento.
 */
class FiltroRepository private constructor(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    init {
        refreshCaches()
    }

    companion object {
        const val DATABASE_NAME = "filtros.db"
        const val DATABASE_VERSION = 3

        const val TABLE_FILTRO = "filtro"
        const val COLUMN_ID = "id"
        const val COLUMN_PREFIJO = "prefijo"
        const val COLUMN_ACTIVO = "activo"
        const val COLUMN_PRIORIDAD = "prioridad"
        const val COLUMN_CREADO_EN = "creado_en"

        const val TABLE_BLOQUEADO = "numero_bloqueado"
        const val COLUMN_NUMERO = "numero_normalizado"
        const val COLUMN_ALIAS = "alias"

        const val TABLE_LISTA_BLANCA = "lista_blanca"

        const val TABLE_REGISTRO = "registro"
        const val COLUMN_MOMENTO = "momento"
        const val COLUMN_NUMERO_ENMASCARADO = "numero_enmascarado"
        const val COLUMN_DECISION = "decision"
        const val COLUMN_TIPO_REGLA = "tipo_regla"
        const val COLUMN_REGLA_REF = "regla_ref"

        @Volatile
        private var INSTANCE: FiltroRepository? = null

        fun getInstance(context: Context): FiltroRepository {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: FiltroRepository(context.applicationContext).also { INSTANCE = it }
            }
        }
    }

    @Volatile
    private var whitelistCache: HashSet<String> = HashSet()

    @Volatile
    private var blockedCache: HashSet<String> = HashSet()

    @Volatile
    private var prefixCache: List<FiltroItem> = emptyList()

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE $TABLE_FILTRO (
                $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_PREFIJO TEXT NOT NULL UNIQUE,
                $COLUMN_ACTIVO INTEGER NOT NULL DEFAULT 1,
                $COLUMN_PRIORIDAD INTEGER NOT NULL DEFAULT 0,
                $COLUMN_CREADO_EN INTEGER NOT NULL
            )
            """.trimIndent()
        )

        db.execSQL(
            """
            CREATE TABLE $TABLE_BLOQUEADO (
                $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_NUMERO TEXT NOT NULL UNIQUE,
                $COLUMN_ALIAS TEXT,
                $COLUMN_ACTIVO INTEGER NOT NULL DEFAULT 1,
                $COLUMN_CREADO_EN INTEGER NOT NULL
            )
            """.trimIndent()
        )

        db.execSQL(
            """
            CREATE TABLE $TABLE_LISTA_BLANCA (
                $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_NUMERO TEXT NOT NULL UNIQUE,
                $COLUMN_ALIAS TEXT,
                $COLUMN_CREADO_EN INTEGER NOT NULL
            )
            """.trimIndent()
        )

        db.execSQL(
            """
            CREATE TABLE $TABLE_REGISTRO (
                $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_MOMENTO INTEGER NOT NULL,
                $COLUMN_NUMERO_ENMASCARADO TEXT NOT NULL,
                $COLUMN_DECISION TEXT NOT NULL,
                $COLUMN_TIPO_REGLA TEXT NOT NULL,
                $COLUMN_REGLA_REF TEXT NOT NULL
            )
            """.trimIndent()
        )

        // Semilla por defecto "400"
        val values = ContentValues().apply {
            put(COLUMN_PREFIJO, "400")
            put(COLUMN_ACTIVO, 1)
            put(COLUMN_PRIORIDAD, 0)
            put(COLUMN_CREADO_EN, System.currentTimeMillis())
        }
        db.insert(TABLE_FILTRO, null, values)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        if (oldVersion < 3) {
            db.execSQL("ALTER TABLE $TABLE_FILTRO ADD COLUMN $COLUMN_PRIORIDAD INTEGER NOT NULL DEFAULT 0")
            db.execSQL(
                """
                CREATE TABLE IF NOT EXISTS $TABLE_BLOQUEADO (
                    $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                    $COLUMN_NUMERO TEXT NOT NULL UNIQUE,
                    $COLUMN_ALIAS TEXT,
                    $COLUMN_ACTIVO INTEGER NOT NULL DEFAULT 1,
                    $COLUMN_CREADO_EN INTEGER NOT NULL
                )
                """.trimIndent()
            )
            db.execSQL(
                """
                CREATE TABLE IF NOT EXISTS $TABLE_LISTA_BLANCA (
                    $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                    $COLUMN_NUMERO TEXT NOT NULL UNIQUE,
                    $COLUMN_ALIAS TEXT,
                    $COLUMN_CREADO_EN INTEGER NOT NULL
                )
                """.trimIndent()
            )
            db.execSQL(
                """
                CREATE TABLE IF NOT EXISTS $TABLE_REGISTRO (
                    $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                    $COLUMN_MOMENTO INTEGER NOT NULL,
                    $COLUMN_NUMERO_ENMASCARADO TEXT NOT NULL,
                    $COLUMN_DECISION TEXT NOT NULL,
                    $COLUMN_TIPO_REGLA TEXT NOT NULL,
                    $COLUMN_REGLA_REF TEXT NOT NULL
                )
                """.trimIndent()
            )
        }
    }

    private fun refreshCaches() {
        val db = readableDatabase

        val whitelistSet = HashSet<String>()
        db.query(TABLE_LISTA_BLANCA, arrayOf(COLUMN_NUMERO), null, null, null, null, null).use { cursor ->
            while (cursor.moveToNext()) {
                whitelistSet.add(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_NUMERO)))
            }
        }
        whitelistCache = whitelistSet

        val blockedSet = HashSet<String>()
        db.query(TABLE_BLOQUEADO, arrayOf(COLUMN_NUMERO), "$COLUMN_ACTIVO = 1", null, null, null, null).use { cursor ->
            while (cursor.moveToNext()) {
                blockedSet.add(cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_NUMERO)))
            }
        }
        blockedCache = blockedSet

        val prefixList = mutableListOf<FiltroItem>()
        db.query(TABLE_FILTRO, null, "$COLUMN_ACTIVO = 1", null, null, null, "$COLUMN_PRIORIDAD DESC, $COLUMN_ID DESC").use { cursor ->
            while (cursor.moveToNext()) {
                val id = cursor.getLong(cursor.getColumnIndexOrThrow(COLUMN_ID))
                val prefijo = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_PREFIJO))
                val activo = cursor.getInt(cursor.getColumnIndexOrThrow(COLUMN_ACTIVO)) == 1
                val prioridad = cursor.getInt(cursor.getColumnIndexOrThrow(COLUMN_PRIORIDAD))
                val creadoEn = cursor.getLong(cursor.getColumnIndexOrThrow(COLUMN_CREADO_EN))
                prefixList.add(FiltroItem(id, prefijo, activo, prioridad, creadoEn))
            }
        }
        prefixCache = prefixList
    }

    fun getRulesForService(): Triple<HashSet<String>, HashSet<String>, List<FiltroItem>> {
        if (whitelistCache.isEmpty() && blockedCache.isEmpty() && prefixCache.isEmpty()) {
            synchronized(this) {
                if (whitelistCache.isEmpty() && blockedCache.isEmpty() && prefixCache.isEmpty()) {
                    refreshCaches()
                }
            }
        }
        return Triple(whitelistCache, blockedCache, prefixCache)
    }

    // CRUD Filtros Prefijo
    fun getAllFilters(): List<FiltroItem> {
        val list = mutableListOf<FiltroItem>()
        readableDatabase.query(TABLE_FILTRO, null, null, null, null, null, "$COLUMN_PRIORIDAD DESC, $COLUMN_CREADO_EN DESC").use { cursor ->
            while (cursor.moveToNext()) {
                val id = cursor.getLong(cursor.getColumnIndexOrThrow(COLUMN_ID))
                val prefijo = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_PREFIJO))
                val activo = cursor.getInt(cursor.getColumnIndexOrThrow(COLUMN_ACTIVO)) == 1
                val prioridad = cursor.getInt(cursor.getColumnIndexOrThrow(COLUMN_PRIORIDAD))
                val creadoEn = cursor.getLong(cursor.getColumnIndexOrThrow(COLUMN_CREADO_EN))
                list.add(FiltroItem(id, prefijo, activo, prioridad, creadoEn))
            }
        }
        return list
    }

    fun insertarFiltro(prefijo: String, prioridad: Int): Result<Long> {
        val validation = MotorFiltrado.validarPrefijo(prefijo)
        if (validation.isFailure) return Result.failure(validation.exceptionOrNull()!!)
        val limpio = validation.getOrThrow()

        val values = ContentValues().apply {
            put(COLUMN_PREFIJO, limpio)
            put(COLUMN_ACTIVO, 1)
            put(COLUMN_PRIORIDAD, prioridad)
            put(COLUMN_CREADO_EN, System.currentTimeMillis())
        }
        return try {
            val id = writableDatabase.insertOrThrow(TABLE_FILTRO, null, values)
            refreshCaches()
            Result.success(id)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun actualizarFiltro(id: Long, prefijo: String, activo: Boolean, prioridad: Int): Result<Unit> {
        val validation = MotorFiltrado.validarPrefijo(prefijo)
        if (validation.isFailure) return Result.failure(validation.exceptionOrNull()!!)
        val limpio = validation.getOrThrow()

        val values = ContentValues().apply {
            put(COLUMN_PREFIJO, limpio)
            put(COLUMN_ACTIVO, if (activo) 1 else 0)
            put(COLUMN_PRIORIDAD, prioridad)
        }
        return try {
            val rows = writableDatabase.update(TABLE_FILTRO, values, "$COLUMN_ID = ?", arrayOf(id.toString()))
            if (rows > 0) {
                refreshCaches()
                Result.success(Unit)
            } else {
                Result.failure(Exception("Filtro no encontrado"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun toggleFiltro(id: Long, activo: Boolean): Result<Unit> {
        val values = ContentValues().apply { put(COLUMN_ACTIVO, if (activo) 1 else 0) }
        return try {
            val rows = writableDatabase.update(TABLE_FILTRO, values, "$COLUMN_ID = ?", arrayOf(id.toString()))
            if (rows > 0) {
                refreshCaches()
                Result.success(Unit)
            } else {
                Result.failure(Exception("Filtro no encontrado"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun eliminarFiltro(id: Long): Result<Unit> {
        return try {
            val rows = writableDatabase.delete(TABLE_FILTRO, "$COLUMN_ID = ?", arrayOf(id.toString()))
            if (rows > 0) {
                refreshCaches()
                Result.success(Unit)
            } else {
                Result.failure(Exception("Filtro no encontrado"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // CRUD Números Bloqueados
    fun getAllBlockedNumbers(): List<NumeroBloqueadoItem> {
        val list = mutableListOf<NumeroBloqueadoItem>()
        readableDatabase.query(TABLE_BLOQUEADO, null, null, null, null, null, "$COLUMN_CREADO_EN DESC").use { cursor ->
            while (cursor.moveToNext()) {
                val id = cursor.getLong(cursor.getColumnIndexOrThrow(COLUMN_ID))
                val numero = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_NUMERO))
                val alias = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_ALIAS))
                val activo = cursor.getInt(cursor.getColumnIndexOrThrow(COLUMN_ACTIVO)) == 1
                val creadoEn = cursor.getLong(cursor.getColumnIndexOrThrow(COLUMN_CREADO_EN))
                list.add(NumeroBloqueadoItem(id, numero, alias, activo, creadoEn))
            }
        }
        return list
    }

    fun insertarNumeroBloqueado(numero: String, alias: String?): Result<Long> {
        val limpio = MotorFiltrado.normalizar(numero)
        if (limpio.isBlank()) return Result.failure(IllegalArgumentException("Número inválido."))
        val values = ContentValues().apply {
            put(COLUMN_NUMERO, limpio)
            put(COLUMN_ALIAS, alias)
            put(COLUMN_ACTIVO, 1)
            put(COLUMN_CREADO_EN, System.currentTimeMillis())
        }
        return try {
            val id = writableDatabase.insertOrThrow(TABLE_BLOQUEADO, null, values)
            refreshCaches()
            Result.success(id)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun toggleNumeroBloqueado(id: Long, activo: Boolean): Result<Unit> {
        val values = ContentValues().apply { put(COLUMN_ACTIVO, if (activo) 1 else 0) }
        return try {
            val rows = writableDatabase.update(TABLE_BLOQUEADO, values, "$COLUMN_ID = ?", arrayOf(id.toString()))
            if (rows > 0) {
                refreshCaches()
                Result.success(Unit)
            } else {
                Result.failure(Exception("Número bloqueado no encontrado"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun eliminarNumeroBloqueado(id: Long): Result<Unit> {
        return try {
            val rows = writableDatabase.delete(TABLE_BLOQUEADO, "$COLUMN_ID = ?", arrayOf(id.toString()))
            if (rows > 0) {
                refreshCaches()
                Result.success(Unit)
            } else {
                Result.failure(Exception("Número bloqueado no encontrado"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // CRUD Lista Blanca
    fun getAllWhitelist(): List<ListaBlancaItem> {
        val list = mutableListOf<ListaBlancaItem>()
        readableDatabase.query(TABLE_LISTA_BLANCA, null, null, null, null, null, "$COLUMN_CREADO_EN DESC").use { cursor ->
            while (cursor.moveToNext()) {
                val id = cursor.getLong(cursor.getColumnIndexOrThrow(COLUMN_ID))
                val numero = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_NUMERO))
                val alias = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_ALIAS))
                val creadoEn = cursor.getLong(cursor.getColumnIndexOrThrow(COLUMN_CREADO_EN))
                list.add(ListaBlancaItem(id, numero, alias, creadoEn))
            }
        }
        return list
    }

    fun insertarWhitelist(numero: String, alias: String?): Result<Long> {
        val limpio = MotorFiltrado.normalizar(numero)
        if (limpio.isBlank()) return Result.failure(IllegalArgumentException("Número inválido."))
        val values = ContentValues().apply {
            put(COLUMN_NUMERO, limpio)
            put(COLUMN_ALIAS, alias)
            put(COLUMN_CREADO_EN, System.currentTimeMillis())
        }
        return try {
            val id = writableDatabase.insertOrThrow(TABLE_LISTA_BLANCA, null, values)
            refreshCaches()
            Result.success(id)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun eliminarWhitelist(id: Long): Result<Unit> {
        return try {
            val rows = writableDatabase.delete(TABLE_LISTA_BLANCA, "$COLUMN_ID = ?", arrayOf(id.toString()))
            if (rows > 0) {
                refreshCaches()
                Result.success(Unit)
            } else {
                Result.failure(Exception("Elemento de lista blanca no encontrado"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // Registro de Actividad y Estadísticas
    fun registrarLlamada(momento: Long, numeroEnmascarado: String, decision: String, tipoRegla: String, reglaRef: String) {
        try {
            val values = ContentValues().apply {
                put(COLUMN_MOMENTO, momento)
                put(COLUMN_NUMERO_ENMASCARADO, numeroEnmascarado)
                put(COLUMN_DECISION, decision)
                put(COLUMN_TIPO_REGLA, tipoRegla)
                put(COLUMN_REGLA_REF, reglaRef)
            }
            writableDatabase.insert(TABLE_REGISTRO, null, values)
        } catch (_: Exception) {}
    }

    fun getAllLogs(): List<RegistroItem> {
        val list = mutableListOf<RegistroItem>()
        readableDatabase.query(TABLE_REGISTRO, null, null, null, null, null, "$COLUMN_MOMENTO DESC", "200").use { cursor ->
            while (cursor.moveToNext()) {
                val id = cursor.getLong(cursor.getColumnIndexOrThrow(COLUMN_ID))
                val momento = cursor.getLong(cursor.getColumnIndexOrThrow(COLUMN_MOMENTO))
                val numEnm = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_NUMERO_ENMASCARADO))
                val decision = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_DECISION))
                val tipoRegla = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_TIPO_REGLA))
                val reglaRef = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_REGLA_REF))
                list.add(RegistroItem(id, momento, numEnm, decision, tipoRegla, reglaRef))
            }
        }
        return list
    }

    fun limpiarLogs() {
        try {
            writableDatabase.delete(TABLE_REGISTRO, null, null)
        } catch (_: Exception) {}
    }

    fun limpiarLogsAntiguos(dias: Int = 30) {
        try {
            val limite = System.currentTimeMillis() - (dias.toLong() * 24 * 60 * 60 * 1000)
            writableDatabase.delete(TABLE_REGISTRO, "$COLUMN_MOMENTO < ?", arrayOf(limite.toString()))
        } catch (_: Exception) {}
    }

    fun getEstadisticas(): Map<String, Any> {
        var totalBloqueadas = 0
        var totalPermitidas = 0
        val porRegla = mutableMapOf<String, Int>()

        readableDatabase.rawQuery("SELECT $COLUMN_DECISION, count(*) FROM $TABLE_REGISTRO GROUP BY $COLUMN_DECISION", null).use { cursor ->
            while (cursor.moveToNext()) {
                val dec = cursor.getString(0)
                val count = cursor.getInt(1)
                if (dec == "BLOQUEADA") totalBloqueadas = count
                else if (dec == "PERMITIDA") totalPermitidas = count
            }
        }

        readableDatabase.rawQuery("SELECT $COLUMN_REGLA_REF, count(*) FROM $TABLE_REGISTRO WHERE $COLUMN_DECISION = 'BLOQUEADA' GROUP BY $COLUMN_REGLA_REF", null).use { cursor ->
            while (cursor.moveToNext()) {
                val regla = cursor.getString(0)
                val count = cursor.getInt(1)
                porRegla[regla] = count
            }
        }

        return mapOf(
            "totalBloqueadas" to totalBloqueadas,
            "totalPermitidas" to totalPermitidas,
            "porRegla" to porRegla
        )
    }
}
