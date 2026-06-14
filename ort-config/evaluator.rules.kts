val copyleftLicenses = licenseClassifications.categories["copyleft"].orEmpty()

fun LicenseView.hasCopyleftLicense(): Boolean =
    licenses.any { license ->
        license.toString() in copyleftLicenses
    }

ruleSet(ortResult, licenseInfoResolver) {
    dependencyRule("GPL_OR_AGPL_LICENSE_IN_DEPENDENCY") {
        require {
            -isExcluded()
            declaredLicenses.hasCopyleftLicense()
        }

        error(
            message = "Dependency ${pkg.id.toCoordinates()} declares a GPL or AGPL license.",
            howToFix = "Review whether this dependency is allowed. If it is approved, add a resolution or adjust the license policy. If it is not approved, replace the dependency."
        )
    }
}