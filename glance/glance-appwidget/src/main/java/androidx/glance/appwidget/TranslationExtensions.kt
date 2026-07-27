package androidx.glance.appwidget

import android.content.Context
import android.widget.RemoteViews
import androidx.glance.Emittable
import androidx.glance.GlanceModifier

/** Internal extension point for leaf emittables backed by custom [RemoteViews]. */
internal interface RemoteViewsTranslatable : Emittable {
    fun createRemoteViews(context: Context): RemoteViews
}

/** Internal extension point for modifiers that need custom RemoteViews operations. */
internal interface RemoteViewsModifierExtension : GlanceModifier.Element {
    fun applyRemoteViews(
        translationContext: TranslationContext,
        remoteViews: RemoteViews,
        viewDef: InsertedViewInfo,
    )
}
