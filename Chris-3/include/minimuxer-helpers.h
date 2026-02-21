#pragma once
// minimuxer-helpers.h
// High-level helper functions wrapping minimuxer + em_proxy startup.

#include "minimuxer.h"
#include "em_proxy.h"
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Full startup sequence: starts em_proxy then minimuxer.
/// @param pairing_data  Raw bytes of .mobiledevicepairing file.
/// @param len           Length of pairing_data.
/// @param error_out     Output buffer for error string (caller must free).
/// @return true on success.
bool chris_start_mux(const uint8_t *pairing_data, uintptr_t len, char **error_out);

/// Tear down em_proxy and minimuxer.
void chris_stop_mux(void);

/// Returns true when the mux is ready for device communication.
bool chris_mux_ready(void);

#ifdef __cplusplus
}
#endif
