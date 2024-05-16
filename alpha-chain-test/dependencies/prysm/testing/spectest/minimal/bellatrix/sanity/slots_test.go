package sanity

import (
	"testing"

	"github.com/prysmaticlabs/prysm/v5/testing/spectest/shared/bellatrix/sanity"
)

func TestMinimal_Bellatrix_Sanity_Slots(t *testing.T) {
	sanity.RunSlotProcessingTests(t, "minimal")
}
