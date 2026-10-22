"""Notification texts per recipient locale (ARCHITECTURE §26). `{task}` is the job title,
`{when}` is a Yerevan date/time like "13.10 09:00"."""

from app.modules.notifications.models import NotificationType as T

_TEMPLATES: dict[T, dict[str, tuple[str, str]]] = {
    T.TASK_ASSIGNED: {
        "hy": ("Նոր առաջադրանք", "{task} · {when}"),
        "ru": ("Новая задача", "{task} · {when}"),
        "en": ("New task assigned", "{task} · {when}"),
        "hi": ("नया काम दिया गया", "{task} · {when}"),
        "id": ("Tugas baru", "{task} · {when}"),
    },
    T.TASK_CHANGED: {
        "hy": ("Առաջադրանքի ժամը փոխվել է", "{task} → {when}"),
        "ru": ("Время задачи изменено", "{task} → {when}"),
        "en": ("Task schedule changed", "{task} → {when}"),
        "hi": ("काम का समय बदल गया", "{task} → {when}"),
        "id": ("Jadwal tugas berubah", "{task} → {when}"),
    },
    T.TASK_CANCELLED: {
        "hy": ("Առաջադրանքը չեղարկվել է", "{task} · {when}"),
        "ru": ("Задача отменена", "{task} · {when}"),
        "en": ("Task cancelled", "{task} · {when}"),
        "hi": ("काम रद्द कर दिया गया", "{task} · {when}"),
        "id": ("Tugas dibatalkan", "{task} · {when}"),
    },
    T.TASK_REMINDER: {
        "hy": ("Հիշեցում", "{task} · {when}"),
        "ru": ("Напоминание", "{task} · {when}"),
        "en": ("Reminder", "{task} · {when}"),
        "hi": ("याद दिलाना", "{task} · {when}"),
        "id": ("Pengingat", "{task} · {when}"),
    },
    T.SUBMISSION_ACCEPTED: {
        "hy": ("Առաջադրանքը ուղարկված է", "{task}"),
        "ru": ("Задача отправлена", "{task}"),
        "en": ("Task submitted successfully", "{task}"),
        "hi": ("काम सफलतापूर्वक भेजा गया", "{task}"),
        "id": ("Tugas berhasil dikirim", "{task}"),
    },
}


# `{when}` of a TASK_REMINDER (§26): the evening before, and 1 hour before the start.
REMINDER_WHEN: dict[str, dict[str, str]] = {
    "tomorrow": {
        "hy": "վաղը {time}, {site}",
        "ru": "завтра в {time}, {site}",
        "en": "tomorrow at {time}, {site}",
        "hi": "कल {time} बजे, {site}",
        "id": "besok pukul {time}, {site}",
    },
    "soon": {
        "hy": "1 ժամից, {time}, {site}",
        "ru": "через 1 час, в {time}, {site}",
        "en": "in 1 hour, at {time}, {site}",
        "hi": "1 घंटे में, {time} बजे, {site}",
        "id": "1 jam lagi, pukul {time}, {site}",
    },
}


def reminder_when(kind: str, locale: str, **params: str) -> str:
    by_locale = REMINDER_WHEN[kind]
    return by_locale.get(locale, by_locale["en"]).format(**params)


def render(type_: T, locale: str, **params: str) -> tuple[str, str]:
    by_locale = _TEMPLATES[type_]
    title, body = by_locale.get(locale, by_locale["en"])
    return title.format(**params), body.format(**params)
