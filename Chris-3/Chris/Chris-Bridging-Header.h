//
//  Chris-Bridging-Header.h
//  Exposes all C library headers to Swift.
//  Set this as the "Objective-C Bridging Header" in Build Settings.
//

// minimuxer (SideStore — Rust)
#include "minimuxer.h"
#include "minimuxer-helpers.h"

// em_proxy (SideStore — Rust)
#include "em_proxy.h"

// SparseRestore / idevicebackup2 (libimobiledevice-based C)
#include "idevicebackup2.h"
