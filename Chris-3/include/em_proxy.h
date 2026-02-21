#pragma once
// em_proxy.h
// Swift-callable C interface to SideStore's em_proxy Rust library.
// em_proxy tunnels the usbmuxd socket over a WireGuard/local network connection.

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Start the em_proxy on the given port.
/// @param port  Local TCP port to listen on (default: 27015).
/// @return 0 on success, non-zero on error.
int em_proxy_start(uint16_t port);

/// Returns true if em_proxy is running.
bool em_proxy_running(void);

/// Stop em_proxy.
void em_proxy_stop(void);

#ifdef __cplusplus
}
#endif
