/// Atomic, combinable capability units that define any screen, workflow, or data stream.
enum AtomicCapability {
  // Clinical & Anatomical Visualization
  clinicalEncounter3dCanvas,   // 3D vector canvas (dental, skeletal, torso, eye, vet, or custom mesh)
  specializedClinicalCharting, // Perio, optical Rx, audiogram, growth curve, antenatal biometry
  diagnosticRadiologyLightbox, // DICOM/X-ray/MRI image analyzer with zoom & contrast tools
  laboratorySpecimenTracking,  // Bloodwork, pathology panels, out-of-range flag badges

  // Physical Inventory & Dispensing
  fefoBatchInventory,          // Expiry dates, drug batches, cold-chain metadata
  standardRetailBarcoding,     // Shelf stock, barcode scanning, reorder thresholds
  consumableAutoDepletion,     // Auto-deduct bandages, syringes, or dyes when procedures are added

  // Service, Booking & Hospitality
  timeSlotAppointmentEngine,  // Doctor appointments, spa slots, room bookings, conflict prevention
  tableFloorMapManagement,    // Dine-in tables, kitchen display tickets (KDS), split billing
  multiSessionPackageCredit,   // Gym memberships, PT packs, course sessions with remaining punch-cards
  multiDayStayBoarding,        // Hotel room night charges, hospital bed, or pet kennel boarding

  // Financial, Commission & Ledger
  multiProviderCommission,    // Split revenue across attending doctor, nurse, therapist, or stylist
  insuranceCopayDeductible,    // Insurance policy calculation, patient debt, company credit ledger
  unifiedCrossDepartmentCart,  // Merge consultations, items, meals, drugs, and services into 1 bill
  unifiedQueueDispatchHub,     // Reception terminal dynamically dispatching tickets across any station
}
