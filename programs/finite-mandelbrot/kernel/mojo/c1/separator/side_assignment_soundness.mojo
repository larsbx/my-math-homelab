# C1_side_assignment_soundness.mojo
#
# Finite scaffold for SideAssignmentSoundness in the C1 bridge.
# This module tracks proof obligations only. It does not claim MLC or generic
# stabilization.

from c1.separator.side_assignment import SideAssignmentWitness, SideLabel


struct LocalSoundnessStatus:
    var ray_order_sound: Bool
    var wake_membership_sound: Bool
    var component_boundary_sound: Bool
    var generic_tags_rejected: Bool
    var on_separator_nonseparating: Bool

    fn __init__(inout self, ray_order_sound: Bool, wake_membership_sound: Bool, component_boundary_sound: Bool, generic_tags_rejected: Bool, on_separator_nonseparating: Bool):
        self.ray_order_sound = ray_order_sound
        self.wake_membership_sound = wake_membership_sound
        self.component_boundary_sound = component_boundary_sound
        self.generic_tags_rejected = generic_tags_rejected
        self.on_separator_nonseparating = on_separator_nonseparating

    fn all_local_lemmas_closed(self) -> Bool:
        return (
            self.ray_order_sound and
            self.wake_membership_sound and
            self.component_boundary_sound and
            self.generic_tags_rejected and
            self.on_separator_nonseparating
        )


fn side_label_can_separate(label: SideLabel) -> Bool:
    return label.name == "Left" or label.name == "Right"


fn on_separator_is_structural(label: SideLabel) -> Bool:
    return label.name == "OnSeparator"


fn finite_side_assignment_soundness_pending() -> LocalSoundnessStatus:
    # RayOrderSoundness, WakeMembershipSoundness, and ComponentBoundarySoundness
    # are not closed in this scaffold. Generic tags and OnSeparator handling are
    # already enforced by earlier finite validators.
    return LocalSoundnessStatus(False, False, False, True, True)


fn next_local_blocker() -> String:
    return "WakeMembershipSoundness"


fn generic_stabilization_not_claimed_by_side_soundness() -> Bool:
    return True
