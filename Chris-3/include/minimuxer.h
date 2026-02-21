#pragma once
// minimuxer.h
// Swift-callable C interface to the minimuxer Rust library.
// Minimuxer creates a local TCP mux that pymobiledevice3 / libimobiledevice
// can connect through, simulating the usbmuxd socket on-device.

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Start the minimuxer with a .mobiledevicepairing file blob.
/// @param pairing_file_content  Raw bytes of the pairing file.
/// @param pairing_file_len      Length of the pairing file in bytes.
/// @return 0 on success, non-zero on error.
int minimuxer_start(const uint8_t *pairing_file_content, uintptr_t pairing_file_len);

/// Returns true if minimuxer is currently running and healthy.
bool minimuxer_ready(void);

/// Stop the minimuxer. Call before app exit.
void minimuxer_stop(void);

/// Returns the last error string from minimuxer, or NULL if none.
const char *minimuxer_last_error(void);

#ifdef __cplusplus
}
#endif
