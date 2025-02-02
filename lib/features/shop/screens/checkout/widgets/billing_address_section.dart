import 'package:ecommerce_app/common/widgets/texts/section_heading.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TbillingAddressSection extends StatelessWidget {
  const TbillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TSectionHeading(title: 'Alamat Pengiriman', buttonTitle: 'edit', onPressed: (){},),
        Text('Galang Rahmad Dhani', style: Theme.of(context).textTheme.bodyLarge,),
        const SizedBox(width: TSizes.spaceBtwItems / 2 ,),
        Row(
          children: [
            const Icon(Icons.phone, color: Colors.grey, size: 16,),
            const SizedBox(width: TSizes.spaceBtwItems,),
            Text('(+62) 821-4078-4672', style: Theme.of(context).textTheme.bodyMedium,)
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2,),
        Row(
          children: [
            const Icon(Icons.location_history, color: Colors.grey, size: 16,),
            const SizedBox(width: TSizes.spaceBtwItems,),
            Expanded(child: Text('Griya Citra Asri Rm 26/27, Surabaya', style: Theme.of(context).textTheme.bodyMedium, softWrap: true,))
          ],
        ),
      ],
    );
  }
}