# Macnman Production Firmware Hex Files

Central repository for **production-release firmware hex files** of Macnman MacSync devices, together with the hardware test result for each build.

Only signed-off, production-ready builds are published here. Development and test builds live in their respective firmware source repositories.

## Model number format

Every device model number encodes its own metadata:

```
MacSync - L B S - TH - X1
   |      | | |    |    |
   |      | | |    |    +-- hardware revision (X1, X2, ...)
   |      | | |    +------- measurement / payload (TH, NS, ToF, DRS, STD, PO)
   |      | | +------------ S = Sensor, D = Datalogger
   |      | +-------------- B = Battery powered, P = externally Powered
   |      +---------------- L = LoRaWAN, M = raw LoRa (point-to-point)
   +----------------------- product family
```

| Position | Code | Meaning |
| --- | --- | --- |
| 1 | `L` | LoRaWAN |
| 1 | `M` | Raw LoRa (point-to-point) |
| 2 | `B` | Battery powered (folder `MacSync_LBO`) |
| 2 | `P` | Externally powered (folder `MacSync_LPO`) |
| 3 | `S` | Sensor |
| 3 | `D` | Datalogger |

Payload codes: `TH` (temperature + humidity), `NS`, `ToF`, `DRS` (door reed switch), `STD`, `PO`.

Worked example — `MacSync-LBD-STD-X1`: LoRaWAN, Battery powered, Datalogger, STD payload, hardware revision X1.

## Repository structure

```
Macnman_Production_Firmware_Hex_Files/
├── MacSync_LBO/                          # LoRa, Battery Operated
│   ├── MacSync_MBS_TH_X1/
│   │   ├── NrF52/                        # BLE build
│   │   │   ├── BLE-MS-MBS-TH-X1.hex
│   │   │   └── hw_result.json
│   │   └── STM32WLE5CBU6/                # LoRa build
│   │       ├── MS-MBS-TH-X1.hex
│   │       └── hw_result.json
│   ├── MacSync_MBS_DRS_X1/
│   │   ├── NrF52/
│   │   │   ├── BLE-MS-MBS-DRS-X1.hex
│   │   │   └── hw_result.json
│   │   └── STM32WLE5CBU6/
│   │       ├── MS-MBS-DRS-X1.hex
│   │       └── hw_result.json
│   └── MS-MPV-X1/
│       ├── NrF52810/
│       │   ├── BLE-MS-MPV-X1.hex
│       │   └── hw_result.json
│       └── STM32WLE5CBU6/
│           ├── MS-MPV-X1.hex
│           └── hw_result.json
└── MacSync_LPO/                          # LoRa, Power Operated
```

Within a device folder, firmware is separated by target MCU:

| MCU folder | Silicon | Radio | Hex file prefix |
| --- | --- | --- | --- |
| `NrF52` | Nordic nRF52 | BLE | `BLE-MS-…` |
| `NrF52810` | Nordic nRF52810 | BLE | `BLE-MS-…` |
| `STM32WLE5CBU6` | ST STM32WLE5CBU6 | LoRa / LoRaWAN | `MS-…` |

### Folder structure convention

Every file in this repository sits at a three-level path:

```
<power-class>/<model>/<mcu>/
        |         |      |
        |         |      +-- MCU the build targets, e.g. NrF52, STM32WLE5CBU6
        |         +--------- device model folder, e.g. MacSync_MBS_TH_X1
        +------------------- MacSync_LBO (battery) or MacSync_LPO (externally powered)
```

| Level | Rule |
| --- | --- |
| `<power-class>` | Determined by **position 2** of the model code: `B` → `MacSync_LBO`, `P` → `MacSync_LPO`. Never create a third top-level folder. |
| `<model>` | One folder per device model, named as the model number with `_` separators (e.g. `MacSync_MBS_TH_X1`). One model per folder — do not place another model's firmware here. |
| `<mcu>` | One folder per target MCU. A device with two MCUs (radio + application) gets one folder each. |

Each `<mcu>` folder contains, and contains only:

- one or more `.hex` firmware images, named per the [file naming convention](#file-naming-convention);
- exactly one `hw_result.json` recording the hardware test outcome for that build.

#### Adding a new device

1. Decode the model number to pick the power class — `B` → `MacSync_LBO`, `P` → `MacSync_LPO`.
2. Create `<power-class>/<model>/` using the model number with `_` separators.
3. Create one `<mcu>/` folder beneath it per target MCU.
4. Add the `.hex` file(s) and an `hw_result.json` to each MCU folder.

Folders are only visible on GitHub once they contain a committed file — an empty folder will not appear.

#### Current deviations

Each model now has its own folder, as required. Three points remain open — see [Naming exceptions to resolve](#naming-exceptions-to-resolve) for detail:

- **`MS-MPV-X1/` is named inconsistently with its siblings.** The other model folders use the full family name with underscores (`MacSync_MBS_TH_X1`); this one uses the abbreviated, hyphenated file-name form. It should be `MacSync_MPV_X1/`.
- **`MS-MPV-X1` is a `P` (externally powered) model filed under `MacSync_LBO`** (battery). It belongs under `MacSync_LPO` if the model code is correct.
- **`MacSync_LPO/` is empty**, so it does not currently appear on GitHub.

MCU folders are named after the silicon. `NrF52810` names an exact part number while `NrF52` names the family; picking one convention and applying it to both would keep paths predictable.

## Hardware test results

Each MCU folder carries an `hw_result.json` recording the outcome of the hardware bring-up tests for that build. Every field is a boolean: `true` = pass, `false` = fail.

```json
{
  "hw_result": {
    "i2c": true,
    "rs485": false,
    "relay_test": false,
    "analog_v": false,
    "analog_c": false,
    "3volt_out": true,
    "pwr_out": false,
    "pwr_in": false,
    "capacitor_charge": true,
    "lora_rf": true
  }
}
```

| Field | Test |
| --- | --- |
| `i2c` | I2C bus communication (e.g. SHT40 sensor) |
| `rs485` | RS485 / Modbus transceiver |
| `relay_test` | Relay switching output |
| `analog_v` | Analog voltage input |
| `analog_c` | Analog current input (4–20 mA) |
| `3volt_out` | 3 V rail output |
| `pwr_out` | Power output rail |
| `pwr_in` | Power input rail |
| `capacitor_charge` | Supercapacitor / storage charge circuit |
| `lora_rf` | LoRa RF transmit / receive |

A field that does not apply to a given board should still be present, set to `false`, so the key set stays uniform across devices.

Fetch a result directly over raw HTTP:

```
https://raw.githubusercontent.com/MacnMan/Macnman_Production_Firmware_Hex_Files/main/<path>/hw_result.json
```

The same base URL serves the hex files:

```
https://raw.githubusercontent.com/MacnMan/Macnman_Production_Firmware_Hex_Files/main/<path>/<file>.hex
```

## Published firmware

| Model | Decoded | Interface | Application | Hex file |
| --- | --- | --- | --- | --- |
| `MacSync-MBS-TH-X1` | raw LoRa · Battery · Sensor · TH · X1 | I2C (SHT40) | V1.1.0 | [MS-MBS-TH-X1.hex](MacSync_LBO/MacSync_MBS_TH_X1/STM32WLE5CBU6/MS-MBS-TH-X1.hex) |
| `MacSync-MBS-DRS-X1` | raw LoRa · Battery · Sensor · DRS · X1 | Digital (door reed) | V1.1.0 | [MS-MBS-DRS-X1.hex](MacSync_LBO/MacSync_MBS_DRS_X1/STM32WLE5CBU6/MS-MBS-DRS-X1.hex) |
| `MacSync-MPV-X1` | does not parse — see below | RS485 | V1.3.0 | [MS-MPV-X1.hex](MacSync_LBO/MS-MPV-X1/STM32WLE5CBU6/MS-MPV-X1.hex) |
| `MacSync-MBS-TH-X1` (BLE build) | BLE build of an `M`-coded model | I2C (SHT40) | _unconfirmed_ | [BLE-MS-MBS-TH-X1.hex](MacSync_LBO/MacSync_MBS_TH_X1/NrF52/BLE-MS-MBS-TH-X1.hex) |
| `MacSync-MBS-DRS-X1` (BLE build) | BLE build of an `M`-coded model | Digital (door reed) | _unconfirmed_ | [BLE-MS-MBS-DRS-X1.hex](MacSync_LBO/MacSync_MBS_DRS_X1/NrF52/BLE-MS-MBS-DRS-X1.hex) |
| `MacSync-MPV-X1` (BLE build) | does not parse — see below | RS485 | _unconfirmed_ | [BLE-MS-MPV-X1.hex](MacSync_LBO/MS-MPV-X1/NrF52810/BLE-MS-MPV-X1.hex) |

Application versions for the LoRa builds are the values reported by the firmware's own `DEVINFO` record. The nRF52 BLE builds embed no version string, so their versions are unconfirmed.

### Naming exceptions to resolve

- **`MPV` does not parse.** The third character `V` is neither `S` (Sensor) nor `D` (Datalogger), and the model has no payload segment between the code and the revision. Its firmware reports `DEVINFO=LORA,NODE,RS485,…`, so it is an RS485 device.
- **`MPV` is `P` (externally powered) but sits under `MacSync_LBO`** (Battery Operated). Either the file is in the wrong folder or the name predates this convention.
- **The BLE builds carry `M`-coded model numbers.** Position 1 of the code denotes LoRa, but these are nRF52 BLE images.
- **Folder `MS-MPV-X1/` uses the hyphenated file-name form**, while sibling model folders use `MacSync_…_X1` with underscores.

## File naming convention

Hex files are named for the model, not the version:

```
[BLE-]MS-<code>-<payload>-<revision>.hex
```

`MS` abbreviates the `MacSync` family; `<code>`, `<payload>` and `<revision>` are the model number segments above. The `BLE-` prefix marks an nRF52 BLE build and is absent on LoRa builds.

## Adding a new firmware release

1. Place the `.hex` file in the matching `<device>/<MCU>/` folder.
2. Name it using the convention above.
3. Add or update `hw_result.json` in that folder with the hardware test outcome for the build.
4. Validate the JSON parses.
5. Commit with a message stating the model and version, e.g. `Add MacSync-MPV-X1 firmware V1.3.0`.
6. Add a row to the release notes below.

## Release notes

| Date | Model | Version | Notes |
| --- | --- | --- | --- |
| 2026-09-04 | `MacSync-MPV-X1` | V1.3.0 | Initial publication |
| 2026-09-04 | `MacSync-MBS-TH-X1` | V1.1.0 | Initial publication |
| 2026-09-04 | `MacSync-MBS-DRS-X1` | V1.1.0 | Initial publication |
| 2026-09-04 | BLE builds | _unconfirmed_ | Initial publication; versions pending confirmation |

## Flashing

Use the standard Macnman production programming setup for the target MCU. Always verify after flashing, and confirm the device reports the expected firmware version before dispatch.

## Notes

- Production hex files are release artifacts — treat them as immutable once committed.
- Do not commit source code, build intermediates, or map files to this repository.

---

© Macnman Technologies. Internal production use.
