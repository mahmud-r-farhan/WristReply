package com.wristreply.core

import com.wristreply.core.nlp.LocationPillResolver
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class LocationPillResolverTest {

    @Test
    fun testEnglishLocationQuery() {
        val pill = LocationPillResolver.resolveLocationPill("Hey where are you?")
        assertEquals("[📍 Location]", pill)

        val pill2 = LocationPillResolver.resolveLocationPill("Can you send your location?")
        assertEquals("[📍 Location]", pill2)
    }

    @Test
    fun testSpanishLocationQuery() {
        val pill = LocationPillResolver.resolveLocationPill("Hola amigo, ¿dónde estás?")
        assertEquals("[📍 Ubicación]", pill)

        val pill2 = LocationPillResolver.resolveLocationPill("Pasa tu ubicacion")
        assertEquals("[📍 Ubicación]", pill2)
    }

    @Test
    fun testGermanLocationQuery() {
        val pill = LocationPillResolver.resolveLocationPill("Hallo, wo bist du?")
        assertEquals("[📍 Standort]", pill)

        val pill2 = LocationPillResolver.resolveLocationPill("Bitte teile deinen Standort")
        assertEquals("[📍 Standort]", pill2)
    }

    @Test
    fun testPortugueseLocationQuery() {
        val pill = LocationPillResolver.resolveLocationPill("Onde você está?")
        assertEquals("[📍 Localização]", pill)

        val pill2 = LocationPillResolver.resolveLocationPill("Manda sua localizacao")
        assertEquals("[📍 Localização]", pill2)
    }

    @Test
    fun testFrenchLocationQuery() {
        val pill = LocationPillResolver.resolveLocationPill("Tu es où ?")
        assertEquals("[📍 Position]", pill)

        val pill2 = LocationPillResolver.resolveLocationPill("Envoie ta position")
        assertEquals("[📍 Position]", pill2)
    }

    @Test
    fun testArabicLocationQuery() {
        val pill = LocationPillResolver.resolveLocationPill("وينك يا غالي؟")
        assertEquals("[📍 موقعي]", pill)

        val pill2 = LocationPillResolver.resolveLocationPill("أين أنت الآن؟")
        assertEquals("[📍 موقعي]", pill2)
    }

    @Test
    fun testHindiLocationQuery() {
        val pill = LocationPillResolver.resolveLocationPill("Bhai kahan ho?")
        assertEquals("[📍 Location]", pill)

        val pillDevanagari = LocationPillResolver.resolveLocationPill("कहाँ हो?")
        assertEquals("[📍 लोकेशन]", pillDevanagari)
    }

    @Test
    fun testBengaliLocationQuery() {
        val pillBanglish = LocationPillResolver.resolveLocationPill("Kothay acho?")
        assertEquals("[📍 Location]", pillBanglish)

        val pillScript = LocationPillResolver.resolveLocationPill("কোথায় আছো?")
        assertEquals("[📍 লোকেশন]", pillScript)
    }

    @Test
    fun testNonLocationQueryReturnsNull() {
        assertNull(LocationPillResolver.resolveLocationPill("How are you doing today?"))
        assertNull(LocationPillResolver.resolveLocationPill("Sounds good, see you tomorrow!"))
        assertNull(LocationPillResolver.resolveLocationPill("¡Muchas gracias por todo!"))
    }
}
