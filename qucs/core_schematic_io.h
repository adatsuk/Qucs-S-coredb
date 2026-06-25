#pragma once

#include <QString>

namespace qucs_core {

struct IoResult {
    bool    ok = false;
    QString message;
};

extern bool g_coreBridgeActive;

bool isCoreSchematicPath(const QString &path);
QString cellNameFromCorePath(const QString &path);

IoResult exportCoreToSchFile(const QString &corePath, const QString &schPath);
IoResult importSchFileToCore(const QString &schPath, const QString &corePath);

qint64 normalizeSchCoordinatesForDisplay(const QString &schPath);
void denormalizeSchCoordinates(const QString &schPath, qint64 divisor);

} // namespace qucs_core
