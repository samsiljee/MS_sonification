# Mass spectrometry sonification
### Sam Siljee - 18th March 2024
I wanted to represent the data in a non-visual format.
Graphics are a logical way and clear way of presenting this data, however I wanted to explore other methods.
Sonification is not a new methodology, however I feel like the data from mass spectrometry is particularly well suited to sonification.

## Tone synthesis
Sonification has been done before with scientific data, most commonly as a dry or simplistic plugging of a multiple series of numbers into a synthesiser to produce an odd string of synthetic piano sounds.
I really wanted the data to be fairly represented and honoured by the produced sound.
Hence I chose to use only a minimal intervention when tonifying the data.
The only synthetic process involved is generating sine waves from the data.
I have also avoided any transformation of the data.
I noticed that the m/z values observed happen to be in the audible range when converted directly to Hz.
The actual process of tonification is straight-forward.
Each spectrum is taken in isolation, and a set of sine waves are generated, one for each peak of the spectrum.
The m/z value is mapped to frequency of the sine wave, and the intensity of the peak is mapped to amplitude of the sine wave.
These sine waves are then summed to produce more complex waveforms and the characteristic tone for each spectrum.
Tones are clipped to a default 1 second.
There is an interesting symmetry in that one of the detectors used in the mass spectrometer for some acquisition methods, the orbitrap, does essentially the opposite process.
The orbitrap takes a set of spinning ions in a magnetic field and detects a complex waveform from which the Fourier transformation is used to resolve groups of ions with very high resolution.

## Piece synthesis
The first test data, "1e6_phospho_converted.mzML" is from a test of sample extraction, phosphopeptide enrichment, and methods of running the mass spectrometer in July 2022.
The orbitrap was used for acquiring this data, resulting in fewer total spectra, but higher-quality with higher accuracy and resolution. 
The dataset contains a total of 58,248 spectra, of which 4,517 and MS1, and 53731 are MS2.
The acquisition method was 90 minutes, and hence the complete piece is also 90 minutes long.

## Background noise
In science, a commonly used term is background-to-noise ratio.
Out of the signal intensity received, how much carries "useful" information as opposed to random noise or technical artifact.
This is analogous to how turning up the volume on the stereo can increase the signal, but not improve the audio quality or improve the signal to noise ratio.

## Process of interpretation
13th of March - In discussion, I came to realise that this process represents an interpretation of my data.
It is a process of taking machine-intelligible sets of millions of datapoints, and transforming it into something that a human can grasp. 
Despite artificial intelligence, machines and humans do not think alike.
This is why programming languages are needed to translate from one world of comprehension to another.
The standard approach to interpreting mass-spectrometry data, is to first statistically process the data to clean it up and summarise the many datapoints into biologically more interpretable summaries.
Firstly the spectra are matched to protein fragments (peptides) from a reference database.
These matched spectra are summarised to those that match the same peptides (protein fragments), these are then further summarised into peptides from the same proteins.
Further interpretation is all about providing context, where samples from different groups are contrasted to look at relative differences.
These proteins which are identified to be different are then referenced against known biological pathways to get biological meaning.

## Challenges
- Coding process
- Computing time - days of computation on a standard desktop computer to sonify a single mass spectrometry run.
An experiment can involve hundreds or thousands of runs.
- Musicality and aesthetics vs letting the data speak for itself.
Objectivity vs subjectivity.
There are ways of artificially coercing data into rhythms and harmonies.
- Dynamic range - Should I use logarithmic scaling of total ion current for tone loudness?
- Click at the triggering of each clip, this is an artifact of all of the sineswave starting in sync, initially some big spikes in the waveform before they move out-of-phase.
- How literal to be
- (Not yet tested), it reflects technicalities of the aquisition method more than biological differences at this point

## Wish-list
- To combine multiple tones into a coherent piece
- Deal with the clicking when clips are triggered
- Use other header data to produce envelops for the sounds, attack, duration, decay etc.
- Visual accompanyment
- Invert m/z values? Heavier ions for lower tones?

## Interpretation of produced sound
The most obvious difference is in the spectra produced by MS1 and MS2.
The MS2 scans show more variety, with the MS1 scans starting off with the machine droning of background noise before the peptides start to enter the mass spectrometer.
At around the 18 minute mark the MS1 channel starts to sound more tonal, with tones waxing and waning as the corresponding peptides elute from the column.
The rhythms in the MS1 scan are initially faster, then slow down as the cycles include progressively more MS2 spectra.
The fixed rhythm is determined by the cycle time of the mass spectrometer acquisition method.
As mentioned previously, background noise is a feature of the produced sound which distorts its clarity, a challenge all scientific observation methods struggle with.
As with standard interpretation, differing peptides are not necessarily distinguishable from the MS1 spectra, presenting as a single tone.
The diversity of the MS2 tones, tinkling away, is what differentiates the peptides and allows us to identify them.
Where the MS1 sounds are repeated as the same peptides are sampled over the course of the run, the MS2 sounds are not repeated - this is a feature of the acquisition method, the dynamic exclusion list, where peaks from the MS1 spectra are excluded from further MS2 analysis after the firs analysis.
This is to free up time for other less intense peaks to be selected for analysis.
In summary I suspect that the sounds heard reflect acquisition methods more so than biological features of the data.

## Visualisation
I?ve had several people ask me about adding a visual component to the work.
I think this is a good idea, especially as the same principles used to generate the sound can be used to generate visuals.
Advice from Matthijs, the screen saver aesthetic has been done to death, and switch people off.
I'm much better off making something mechanical, automaton like.

Ideas for automata: 
- 2D array of rods with adjustable height.
Bin the peaks, and adjust heights as a histogram.
Have the retention time scroll across the other dimension of the array.
- 2D array of rods with the first row representing MS1 spectrum, and the 20 other rows representing the top 20 MS2 associated with that MS1.
This way there?s far less movement in the system, as they only have to refresh once per cycle time period.
- The rods can be covered in a cloth to smooth the peaks, this would also add a screen for illumination if needed.
- Bouncing light of the surface of a wave pool

## Bibliography
(1)

## References
1.	Gulland A. The neuroscientist formerly known as Prince's audio engineer. Nature [Internet]. 2024 Mar 14 [cited 2024 Mar 19]; Available from: https://www.nature.com/articles/d41586-024-00791-5

## Resources
https://mlaetsc.hcommons.org/2023/01/18/data-sonification-for-beginners/
