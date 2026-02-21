#pragma once
// idevicebackup2.h — Chris restore API header

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    CHRIS_OK                    = 0,
    CHRIS_ERR_NO_DEVICE         = 1,
    CHRIS_ERR_LOCKDOWN_FAILED   = 2,
    CHRIS_ERR_BACKUP_FAILED     = 3,
    CHRIS_ERR_RESTORE_FAILED    = 4,
    CHRIS_ERR_FILE_NOT_FOUND    = 5,
    CHRIS_ERR_PLIST             = 6,
} ChrisError;

typedef void (*progress_cb_t)(float progress, const char *message, void *context);

/// Restore an arbitrary file to the device using SparseRestore.
int chris_sparserestore_file(
    const char *udid,
    const char *domain,
    const char *relative_path,
    const uint8_t *file_data,
    size_t file_size,
    progress_cb_t progress_cb,
    void *context
);

/// Restore the MobileGestalt plist (main tweak engine).
int chris_restore_mobilegestalt(
    const char *udid,
    const uint8_t *plist_data,
    size_t plist_size,
    progress_cb_t progress_cb,
    void *context
);

/// Restore the SpringBoard preferences plist.
int chris_restore_springboard_plist(
    const char *udid,
    const uint8_t *plist_data,
    size_t plist_size,
    progress_cb_t progress_cb,
    void *context
);

/// Disable a launchd daemon by name.
int chris_disable_daemon(
    const char *udid,
    const char *daemon_id,
    progress_cb_t progress_cb,
    void *context
);

#ifdef __cplusplus
}
#endif
