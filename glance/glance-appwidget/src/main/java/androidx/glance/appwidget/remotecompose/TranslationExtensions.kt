package androidx.glance.appwidget.remotecompose

import androidx.compose.remote.creation.modifiers.RecordingModifier
import androidx.glance.Emittable
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.remotecompose.components.RcElement

/** Internal extension point for emittables with a native RemoteCompose representation. */
internal interface RemoteComposeTranslatable : Emittable {
    fun translateRemoteCompose(translationContext: TranslationContext): RcElement
}

/** Internal extension point for modifiers with native RemoteCompose behavior. */
internal interface RemoteComposeModifierExtension : GlanceModifier.Element {
    fun applyRemoteCompose(
        translationContext: TranslationContext,
        outputModifier: RecordingModifier,
    )
}
