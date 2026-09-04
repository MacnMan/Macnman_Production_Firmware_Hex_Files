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
4. Add the `.hex` file(s) to each MCU folder.
5. **Add an `hw_result.json` to each MCU folder listing exactly the tests that model requires** — see [Rule: list only the tests that model requires](#rule-list-only-the-tests-that-model-requires). Never copy another model's file across unchanged.

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
    "3volt_out": true,
    "capacitor_charge": true,
    "lora_rf": true
  }
}
```

### Rule: list only the tests that model requires

**`hw_result.json` contains one entry per test the board actually has — and nothing else.**

Do not pad the file with tests the hardware does not implement. A `false` must always mean *this test ran and failed*. If absent keys were written as `false`, a genuine failure would be indistinguishable from a test that was never applicable, and the file stops being a usable QA record.

The key set therefore **varies by model**. Consumers must not assume a fixed set of keys — read whichever keys are present, and treat a missing key as "not applicable to this board".

### Test catalogue

| Field | Test | Required when |
| --- | --- | --- |
| `lora_rf` | LoRa RF transmit / receive | Model code position 1 is `L` or `M` |
| `i2c` | I2C bus communication (e.g. SHT40) | Board carries an I2C sensor |
| `rs485` | RS485 / Modbus transceiver | Interface is RS485 |
| `relay_test` | Relay switching output | Board has a relay output |
| `analog_v` | Analog voltage input | Board has an analog voltage input |
| `analog_c` | Analog current input (4–20 mA) | Board has a 4–20 mA input |
| `pwr_in` | Power input rail | Model code position 2 is `P` |
| `pwr_out` | Power output rail | Board supplies power to an external sensor |
| `capacitor_charge` | Supercapacitor / storage charge circuit | Model code position 2 is `B` |
| `3volt_out` | 3 V rail output | Always — every board has this rail |

Three of these are decided by the model number alone, so they need no judgement:

- position 1 `L`/`M` → include `lora_rf`
- position 2 `B` → include `capacitor_charge`
- position 2 `P` → include `pwr_in`

The rest depend on what is fitted to the board — confirm against the schematic, not the model number.

### Worked example

`MacSync-MBS-TH-X1` decodes to raw LoRa · Battery · Sensor · TH, on an I2C SHT40. Required tests: `lora_rf` (M), `capacitor_charge` (B), `i2c` (SHT40 fitted), `3volt_out` (always). It has no RS485, no relay and no analog inputs, so those five keys are omitted entirely:

```json
{
  "hw_result": {
    "lora_rf": true,
    "capacitor_charge": true,
    "i2c": true,
    "3volt_out": true
  }
}
```

### The six current files do not follow this rule

Every `hw_result.json` in the repository today is an identical copy of the same ten-field sample. They must each be replaced with that board's real required set and real measured values. Two are provably wrong as they stand:

- **Both BLE folders claim `lora_rf`.** `NrF52/` and `NrF52810/` hold Bluetooth images; there is no LoRa radio to test. A BLE radio test field is needed instead — the catalogue above has no name for one yet.
- **`MacSync_MBS_TH_X1` claims `rs485: false`** though it is an I2C temperature/humidity board, and **`MS-MPV-X1` also claims `rs485: false`** though its firmware reports `DEVINFO=LORA,NODE,RS485,…` and it certainly does have RS485.

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
3. **Add or update `hw_result.json` in that folder.** This step is mandatory for every new model number — derive the required key set from the model code and the board, per [Rule: list only the tests that model requires](#rule-list-only-the-tests-that-model-requires), and record real measured values. A new model must never inherit another model's file unchanged.
4. Validate the JSON parses and that its key set matches the tests that model actually has.
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
