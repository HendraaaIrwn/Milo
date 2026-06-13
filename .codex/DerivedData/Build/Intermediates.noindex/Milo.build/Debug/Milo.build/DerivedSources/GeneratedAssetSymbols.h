#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "Body" asset catalog image resource.
static NSString * const ACImageNameBody AC_SWIFT_PRIVATE = @"Body";

/// The "CloseLeftEye" asset catalog image resource.
static NSString * const ACImageNameCloseLeftEye AC_SWIFT_PRIVATE = @"CloseLeftEye";

/// The "CloseRightEye" asset catalog image resource.
static NSString * const ACImageNameCloseRightEye AC_SWIFT_PRIVATE = @"CloseRightEye";

/// The "CommandLine" asset catalog image resource.
static NSString * const ACImageNameCommandLine AC_SWIFT_PRIVATE = @"CommandLine";

/// The "Mouth" asset catalog image resource.
static NSString * const ACImageNameMouth AC_SWIFT_PRIVATE = @"Mouth";

/// The "halfCloseLeftEye" asset catalog image resource.
static NSString * const ACImageNameHalfCloseLeftEye AC_SWIFT_PRIVATE = @"halfCloseLeftEye";

/// The "halfCloseRightEye" asset catalog image resource.
static NSString * const ACImageNameHalfCloseRightEye AC_SWIFT_PRIVATE = @"halfCloseRightEye";

/// The "leftEye" asset catalog image resource.
static NSString * const ACImageNameLeftEye AC_SWIFT_PRIVATE = @"leftEye";

/// The "leftPupil" asset catalog image resource.
static NSString * const ACImageNameLeftPupil AC_SWIFT_PRIVATE = @"leftPupil";

/// The "rightEye" asset catalog image resource.
static NSString * const ACImageNameRightEye AC_SWIFT_PRIVATE = @"rightEye";

/// The "rightPupil" asset catalog image resource.
static NSString * const ACImageNameRightPupil AC_SWIFT_PRIVATE = @"rightPupil";

#undef AC_SWIFT_PRIVATE
