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
├── MacSync_LBO/                              # LoRa, Battery Operated
│   ├── MacSync_MBS_TH_X1/
│   │   ├── hw_result.json                    # one per model
│   │   ├── Application/                      # shipping firmware
│   │   │   ├── NrF52/
│   │   │   │   └── BLE-MS-MBS-TH-X1.hex
│   │   │   └── STM32WLE5CBU6/
│   │   │       └── MS-MBS-TH-X1.hex
│   │   └── Testing/                          # JIG test firmware
│   │       ├── NrF52810/
│   │       │   └── nRF52810_JIG_Testing.hex
│   │       └── STM32WLE5CBU6/
│   │           └── LoRa_Jig_Testing_SHT40_Sensor.hex
│   └── MacSync_MBS_DRS_X1/
│       ├── hw_result.json
│       ├── Application/
│       │   ├── NrF52810/
│       │   │   └── BLE-MS-MBS-DRS-X1.hex
│       │   └── STM32WLE5CBU6/
│       │       └── MS-MBS-DRS-X1.hex
│       └── Testing/
│           ├── NrF52810/
│           │   └── nRF52810_JIG_Testing.hex
│           └── STM32WLE5CBU6/
│               └── LoRa_Jig_Testing_SHT40_Sensor.hex
└── MacSync_LPO/                              # LoRa, Power Operated
    └── MS-MPV-X1/
        ├── hw_result.json
        ├── Application/
        │   ├── NrF52810/
        │   │   └── BLE-MS-MPV-X1.hex
        │   └── STM32WLE5CBU6/
        │       └── MS-MPV-X1.hex
        └── Testing/
            ├── NrF52/
            │   └── nRF52810_JIG_Testing.hex
            └── STM32WLE5CBU6/
                └── LoRa__Jig_Boards_Testing_final.hex
```

Within each stage folder, firmware is separated by target MCU:

| MCU folder | Silicon | Radio | Hex file prefix |
| --- | --- | --- | --- |
| `NrF52` | Nordic nRF52 | BLE | `BLE-MS-…` |
| `NrF52810` | Nordic nRF52810 | BLE | `BLE-MS-…` |
| `STM32WLE5CBU6` | ST STM32WLE5CBU6 | LoRa / LoRaWAN | `MS-…` |

### Folder structure convention

Firmware sits at a four-level path:

```
<power-class>/<model>/<stage>/<mcu>/
        |         |       |      |
        |         |       |      +-- MCU the build targets, e.g. NrF52810, STM32WLE5CBU6
        |         |       +--------- Application or Testing
        |         +----------------- device model folder, e.g. MacSync_MBS_TH_X1
        +--------------------------- MacSync_LBO (battery) or MacSync_LPO (externally powered)
```

| Level | Rule |
| --- | --- |
| `<power-class>` | Determined by **position 2** of the model code: `B` → `MacSync_LBO`, `P` → `MacSync_LPO`. Never create a third top-level folder. |
| `<model>` | One folder per device model, named as the model number with `_` separators (e.g. `MacSync_MBS_TH_X1`). One model per folder — do not place another model's firmware here. |
| `<stage>` | `Application` for the production firmware the device ships with; `Testing` for the JIG firmware used to bring the board up on the test fixture. |
| `<mcu>` | One folder per target MCU. A device with two MCUs (radio + application) gets one folder each. |

Each `<mcu>` folder contains only `.hex` firmware images, named per the [file naming convention](#file-naming-convention).

**Exactly one `hw_result.json` per model**, at the model folder root — the level that holds `Application/` and `Testing/`. There is no `hw_result.json` inside the stage or MCU folders.

#### Adding a new device

1. Decode the model number to pick the power class — `B` → `MacSync_LBO`, `P` → `MacSync_LPO`.
2. Create `<power-class>/<model>/` using the model number with `_` separators.
3. Create `Application/` and `Testing/` beneath it, and one `<mcu>/` folder inside each per target MCU.
4. Put the shipping `.hex` in `Application/<mcu>/` and the JIG test `.hex` in `Testing/<mcu>/`.
5. **Add one `hw_result.json` at the model folder root.** List every `.hex` under `firmware`, and include exactly the tests this model requires — see [Rule: list only the tests that model requires](#rule-list-only-the-tests-that-model-requires). Never copy another model's file across unchanged.

Folders are only visible on GitHub once they contain a committed file — an empty folder will not appear.

#### Current deviations

Each model has its own folder, and `MS-MPV-X1` sits under `MacSync_LPO` as its `P` code requires. Three points remain open — see [Naming exceptions to resolve](#naming-exceptions-to-resolve) for detail:

- **`MS-MPV-X1/` is named inconsistently with its siblings.** The other model folders use the full family name with underscores (`MacSync_MBS_TH_X1`); this one uses the abbreviated, hyphenated file-name form. It should be `MacSync_MPV_X1/`.
- **MCU folder names are inconsistent.** `MacSync_MBS_TH_X1/Application/` and `MS-MPV-X1/Testing/` use `NrF52`, while everywhere else uses `NrF52810` — including folders holding the same `nRF52810_JIG_Testing.hex`. Pick either the exact part number or the family and apply it everywhere.
- **`MS-MPV-X1` carries older JIG firmware than the other two models.** It still holds `LoRa__Jig_Boards_Testing_final.hex` and the earlier `nRF52810_JIG_Testing.hex`, where `MacSync_MBS_TH_X1` and `MacSync_MBS_DRS_X1` have moved to `LoRa_Jig_Testing_SHT40_Sensor.hex` and a newer nRF build. Confirm whether MPV should be updated too.

## Hardware test results

Each model folder carries exactly one `hw_result.json`, recording the firmware it holds and the outcome of the JIG hardware tests. Every test field is a boolean: `true` = pass, `false` = fail.

```json
{
  "firmware": {
    "application": [
      "Application/NrF52/BLE-MS-MBS-TH-X1.hex",
      "Application/STM32WLE5CBU6/MS-MBS-TH-X1.hex"
    ],
    "testing": [
      "Testing/NrF52810/nRF52810_JIG_Testing.hex",
      "Testing/STM32WLE5CBU6/LoRa_Jig_Testing_SHT40_Sensor.hex"
    ]
  },
  "hw_result": {
    "i2c": true,
    "3volt_out": true,
    "capacitor_charge": true,
    "lora_rf": true
  }
}
```

### The firmware field

`firmware` lists every `.hex` present under the model folder, split by stage, as paths relative to the model folder itself.

| Key | Contents |
| --- | --- |
| `application` | Every `.hex` under `Application/`, across all MCU folders. |
| `testing` | Every `.hex` under `Testing/`. Empty array when no JIG firmware exists yet. |

The model number is deliberately **not** stored in the file — it is already the name of the folder the file sits in, and duplicating it only creates a second place to get it wrong.

#### Keeping the lists in sync

**Nothing updates these lists automatically.** Git tracks the `.hex` files and the JSON as unrelated blobs; it has no idea the JSON quotes those paths. Rename an MCU folder or swap in a differently-named build, and the commit succeeds while the JSON silently keeps pointing at a file that no longer exists.

Run the helper after any firmware change, before committing:

```bash
./tools/update_firmware_lists.sh            # rewrite the lists from disk
./tools/update_firmware_lists.sh --check    # report only; exit 1 if stale
```

It rebuilds only the `firmware` block and leaves `hw_result` untouched. The `--check` form is safe to wire into a pre-commit hook or CI job so a stale list fails loudly instead of shipping.

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
| `led_test` | Status / indicator LED | Board has an indicator LED |
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

### The current files do not follow this rule

The `firmware` lists are correct — they are generated from the folder contents. The `hw_result` block is not: all three files carry the same ten-field sample. Each must be replaced with that board's real required key set and real measured values. Two problems are provable as they stand:

- **`MacSync_MBS_TH_X1` claims `rs485: false`** though it is an I2C temperature/humidity board. The key should be absent, not `false`.
- **`MS-MPV-X1` claims `rs485: false`** though its firmware reports `DEVINFO=LORA,NODE,RS485,…`. It has RS485, so the test should be present and its real result recorded.

Note also that each model builds for a BLE MCU as well as a LoRa one, but there is a single `hw_result` block per model and no BLE radio test in the catalogue. If the JIG tests the two MCUs separately, the file needs a way to express that.

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
| `MacSync-MBS-TH-X1` | raw LoRa · Battery · Sensor · TH · X1 | I2C (SHT40) | V1.1.0 | [MS-MBS-TH-X1.hex](MacSync_LBO/MacSync_MBS_TH_X1/Application/STM32WLE5CBU6/MS-MBS-TH-X1.hex) |
| `MacSync-MBS-DRS-X1` | raw LoRa · Battery · Sensor · DRS · X1 | Digital (door reed) | V1.1.0 | [MS-MBS-DRS-X1.hex](MacSync_LBO/MacSync_MBS_DRS_X1/Application/STM32WLE5CBU6/MS-MBS-DRS-X1.hex) |
| `MacSync-MPV-X1` | does not parse — see below | RS485 | V1.3.0 | [MS-MPV-X1.hex](MacSync_LPO/MS-MPV-X1/Application/STM32WLE5CBU6/MS-MPV-X1.hex) |
| `MacSync-MBS-TH-X1` (BLE build) | BLE build of an `M`-coded model | I2C (SHT40) | _unconfirmed_ | [BLE-MS-MBS-TH-X1.hex](MacSync_LBO/MacSync_MBS_TH_X1/Application/NrF52/BLE-MS-MBS-TH-X1.hex) |
| `MacSync-MBS-DRS-X1` (BLE build) | BLE build of an `M`-coded model | Digital (door reed) | _unconfirmed_ | [BLE-MS-MBS-DRS-X1.hex](MacSync_LBO/MacSync_MBS_DRS_X1/Application/NrF52810/BLE-MS-MBS-DRS-X1.hex) |
| `MacSync-MPV-X1` (BLE build) | does not parse — see below | RS485 | _unconfirmed_ | [BLE-MS-MPV-X1.hex](MacSync_LPO/MS-MPV-X1/Application/NrF52810/BLE-MS-MPV-X1.hex) |

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
